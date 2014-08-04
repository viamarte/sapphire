#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 22/05/2013

#This is Sapphire's testing spec file

#Assertion libraries
chai = require "chai"
sinon = require "sinon"
chai.should()
expect = chai.expect

# Testing dependencies

#Require Tedious request module
Request = require("tedious").Request

#Require model
Sapphire = require '../lib'

#Require DBPM
DBPM = require '../lib/DBPM.js'

# Setting test server according to config file
server = DBPM.config.testingServer

#Database instance for the model tests
db = null

#Test suite
describe "Sapphire", ->
  describe "db errors", ->
    it "should emit databaseError if SP not found", (done) ->
      db = new Sapphire server, "foobarbaz"

      db.once "databaseError", ->
        done()

      db.execute()

  describe "event emitter", ->
    describe "connection events", ->
      it "should emit serverNotOnList when server isn't registered", (done) ->
        db = new Sapphire "dumbserver", "sptest"

        db.once "serverNotOnList", (server) ->
          done()

        db.execute()

    describe "validation events", ->
      it "should not accept undefined parameters", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "varchar"
              value: undefined
            }
          ]

        db.once "parameterNotDefined", (parameter) ->
          done()

        db.execute()

      it "should accept requests without parameters", (done) ->
        db = new Sapphire server, "sp_tables"

        db.once "results", ->
          done()

        db.execute()

      it "should emit invalidDataType if applicable", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "invalidType"
              value: "ABCDE"
            }
          ]

        db.once "invalidDataType", (parameter) ->
          done()

        db.execute()

      it "should emit sizeOutOfBounds when type is varchar if set", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "varchar"
              value: "ABCDE"
              maxValue: 4
            }
          ]

        db.once "sizeOutOfBounds", (parameter) ->
          done()

        db.execute()

      it "should emit sizeOutOfBounds when type is int if applicable", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "int"
              value: 12
              maxValue: 11
              minValue: 5
            }
          ]

          db.once "sizeOutOfBounds", (parameter) ->
            done()

          db.execute()

      it "should emit notOnlyNumbers if other applicable", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "varchar"
              value: "999B00B1"
              onlyNumbers: true
            }
          ]

        db.once "notOnlyNumbers", (parameter) ->
          done()

        db.execute()

      it "should emit notOnlyLettersAndSymbols if applicable", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "varchar"
              value: "ABC;9GF"
              onlyLettersAndSymbols: true
            }
          ]

        db.once "notOnlyLettersAndSymbols", (parameter) ->
          done()

        db.execute()

      it "should emit notOnlyLetters if applicable", (done) ->
        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P",
          [
            {
              name: "table_name"
              type: "varchar"
              value: "ABC ; DFD"
              onlyLetters: true
            }
          ]

        db.once "notOnlyLetters", (parameter) ->
          done()

        db.execute()

  describe "supported types:", ->
    it "should support varchar", (done) ->
      params = [
        {
          name: "DataTypeVarChar"
          type: "varchar"
          value: "TESTING"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "TESTING" then done()

      db.execute()

    it "should support text", (done) ->
      params = [
        {
          name: "DataTypeText"
          type: "text"
          value: "TESTING 123"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "TESTING 123" then done()

      db.execute()

    it "should support char", (done) ->
      params = [
        {
          name: "DataTypeChar"
          type: "char"
          value: "TESTING"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR.trim() == "TESTING" then done()

      db.execute()

    it "should support nvarchar", (done) ->
      params = [
        {
          name: "DataTypeNVarChar"
          type: "nvarchar"
          value: "华"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "华" then done()

      db.execute()

    it "should support ntext", (done) ->
      params = [
        {
          name: "DataTypeNVarChar"
          type: "ntext"
          value: "責任"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "責任" then done()

      db.execute()

    it "should support nchar", (done) ->
      params = [
        {
          name: "DataTypeNVarChar"
          type: "nchar"
          value: "義務"
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "義務" then done()

      db.execute()

    it "should support tinyint", (done) ->
      params = [
        {
          name: "DataTypeTinyInt"
          type: "tinyint"
          value: 20
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 20 then done()

      db.execute()

    it "should support smallint", (done) ->
      params = [
        {
          name: "DataTypeSmallInt"
          type: "smallint"
          value: 15000
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 15000 then done()

      db.execute()

    it "should support int", (done) ->
      params = [
        {
          name: "DataTypeInt"
          type: "int"
          value: 50000
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 50000 then done()

      db.execute()

    it "should support bigint", (done) ->
      params = [
        {
          name: "DataTypeBigInt"
          type: "bigint"
          value: 2147483692
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "2147483692" then done()

      db.execute()

    it "should support bit", (done) ->
      params = [
        {
          name: "DataTypeBit"
          type: "bit"
          value: true
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == true then done()

      db.execute()

    it "should support datetime", (done) ->
      date = new Date("December 31, 2012 12:00:00.000")
      params = [
        {
          name: "DataTypeDateTime"
          type: "datetime"
          value: date
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        comparison = resultArray[0].MR - date
        if comparison == 0 then done()

      db.execute()

    it "should support smalldatetime", (done) ->
      date = new Date("December 31, 2012 12:49")
      params = [
        {
          name: "DataTypeSmallDateTime"
          type: "smalldatetime"
          value: date
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        comparison = resultArray[0].MR - date
        if comparison == 0 then done()

      db.execute()

    it "should support date", (done) ->
      date = new Date("December 31, 2012 00:00:00.000")
      params = [
        {
          name: "DataTypeDate"
          type: "date"
          value: date
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "2012-12-31" then done()

      db.execute()

    it "should support time", (done) ->
      date = new Date("December 31, 2012 12:49:00.000")
      params = [
        {
          name: "DataTypeTime"
          type: "time"
          value: date
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == "12:49:00.0000000" then done()

      db.execute()

    it "should support float", (done) ->
      params = [
        {
          name: "DataTypeFloat"
          type: "float"
          value: 123.5
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 123.5 then done()

      db.execute()

    it "should support numeric", (done) ->
      params = [
        {
          name: "DataTypeNumeric"
          type: "numeric"
          value: 123.555
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 123.555 then done()

      db.execute()

    it "should support money", (done) ->
      params = [
        {
          name: "DataTypeMoney"
          type: "money"
          value: 580.5870
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == 580.5870 then done()

      db.execute()

    it "should support uniqueidentifier", (done) ->
      uid = "6F9619FF-8B86-D011-B42D-00C04FC964FF"
      params = [
        {
          name: "DataTypeUniqueIdentifier"
          type: "uniqueidentifier"
          value: uid
        }
      ]

      db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

      db.once "results", (resultArray) ->
        if resultArray[0].MR == uid then done()

      db.execute()

  describe "type overflow testing", ->
    describe "when passing data out of bounds", ->
      it "should truncate char when length out of bounds", (done) ->
        params = [
          {
            name: "DataTypeChar"
            type: "char"
            value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ12345"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "results", (resultArray) ->
          if resultArray[0].MR == "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234"
            done()

        db.execute()

      it "should emit error when tinyint is out of bounds", (done) ->
        params = [
          {
            name: "table_name"
            type: "tinyint"
            value: 256
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error when smallint is out of bounds", (done) ->
        params = [
          {
            name: "DataTypeSmallInt"
            type: "smallint"
            value: 32768
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error when int is out of bounds", (done) ->
        params = [
          {
            name: "DataTypeInt"
            type: "int"
            value: 2147483648
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error when bigint is out of bounds", (done) ->
        params = [
          {
            name: "DataTypeBigInt"
            type: "bigint"
            value: 9223372036854775806
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error on datetime out of range", (done) ->
        params = [
          {
            name: "DataTypeDateTime"
            type: "datetime"
            value: new Date("December 31, 1002 23:59:59.997")
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error on smalldate out of range", (done) ->
        params = [
          {
            name: "DataTypeSmallDateTime"
            type: "smalldatetime"
            value: new Date("June 07, 2079 23:59")
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error on date out of range", (done) ->
        params = [
          {
            name: "DataTypeDate"
            type: "date"
            value: new Date("December 31, 10000")
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

      it "should emit error on time out of range", (done) ->
        params = [
          {
            name: "DataTypeTime"
            type: "time"
            value: new Date("December 31, 10000 23:59:59.9999999")
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "sizeOutOfBounds", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()

    describe "when passing wrong data for type", ->
      it "should emit error on passing text on tinyint", (done) ->
        params = [
          {
            name: "DataTypeTinyInt"
            type: "tinyint"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on smallint", (done) ->
        params = [
          {
            name: "DataTypeSmallInt"
            type: "smallint"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on int", (done) ->
        params = [
          {
            name: "DataTypeInt"
            type: "int"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on bigint", (done) ->
        params = [
          {
            name: "DataTypeBigInt"
            type: "bigint"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on bit", (done) ->
        params = [
          {
            name: "DataTypeBit"
            type: "bit"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on money", (done) ->
        params = [
          {
            name: "DataTypeMoney"
            type: "money"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on numeric", (done) ->
        params = [
          {
            name: "DataTypeNumeric"
            type: "numeric"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing text on float", (done) ->
        params = [
          {
            name: "DataTypeFloat"
            type: "float"
            value: "TESTING"
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on varchar", (done) ->
        params = [
          {
            name: "DataTypeVarChar"
            type: "varchar"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on nvarchar", (done) ->
        params = [
          {
            name: "DataTypeNVarChar"
            type: "nvarchar"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on char", (done) ->
        params = [
          {
            name: "DataTypeChar"
            type: "char"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on nchar", (done) ->
        params = [
          {
            name: "DataTypeNChar"
            type: "nchar"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on text", (done) ->
        params = [
          {
            name: "DataTypeText"
            type: "text"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing int on ntext", (done) ->
        params = [
          {
            name: "DataTypeNText"
            type: "text"
            value: 1
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
      it "should emit error on passing boolean on uniqueidentifier", (done) ->
        params = [
          {
            name: "DataTypeUniqueIdentifier"
            type: "uniqueidentifier"
            value: true
          }
        ]

        db = new Sapphire server, "ViaMARTE.dbo.sp_NODE_With_P", params

        db.once "dataTypeMismatch", (msg) ->
          done()

        db.once "results", (resultArray) ->
          console.error "Result unexpected!"

        db.execute()
