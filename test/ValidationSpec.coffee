#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 22/05/2013

#This is Validation's testing spec file

#Assertion libraries
chai = require "chai"
sinon = require "sinon"
chai.should()
expect = chai.expect

# Testing dependencies

#Require Sapphire
Sapphire = require '../lib'

#Require DBPM
DBPM = require '../lib/DBPM.js'

# Setting test server according to config file
server = DBPM.config.testingServer

#Database instance for the DBPM tests
db = new Sapphire server, "dbo.sp_NODE_Without_P"

describe "Validation", ->
  describe "size checking", ->

    it "should accept no size parameters as a valid option", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "TEST"
      ]

      expect(db.isValid(params)).to.be.true

    it "should check for minimum size property (minValue)", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "TEST"
        minValue: 6
      ]

      expect(db.isValid(params)).to.be.false

    it "should check for maximum size property (maxValue)", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "TEST"
        maxValue: 3
      ]

      expect(db.isValid(params)).to.be.false

    it "should check for a minValue/maxValue range", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "TEST"
        minValue: 2
        maxValue: 3
      ]

      expect(db.isValid(params)).to.be.false

    it "should check for minValue on int type", ->

      params = [
        name: "cDado"
        type: "int"
        value: 2
        minValue: 3
      ]

      expect(db.isValid(params)).to.be.false

    it "should check for maxValue on int type", ->

      params = [
        name: "cDado"
        type: "int"
        value: 2
        maxValue: 4
      ]

      expect(db.isValid(params)).to.be.true

    it "should check for ranges on int type", ->

      params = [
        name: "cDado"
        type: "int"
        value: 2
        minValue: 0
        maxValue: 1
      ]

      expect(db.isValid(params)).to.be.false

    it "should accept valid types", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "TEST"
        minValue: 2
        maxValue: 5
      ]

      expect(db.isValid(params)).to.be.true

    it "should ignore when setting minValue and maxValue in invalid type", ->
      params = [
        name: "cDado"
        type: "bit"
        value: true
        minValue: 12
        maxValue: 36
      ]

      expect(db.isValid(params)).to.be.true

    it "should check for min and max values for dates", ->
      params = [
        name: "cDado"
        type: "datetime"
        value: new Date "June 06, 2013, 12:00"
        minValue: new Date "June 05, 2013, 12:00"
        maxValue: new Date "June 07, 2013, 12:00"
      ]

      expect(db.isValid(params)).to.be.true

  describe "type checking", ->
    it "should not accept wierd types", ->

      params = [
        name: "cDado"
        type: "dumbtype"
        value: "TEST"
      ]

      expect(db.isValid(params)).to.be.false

  describe "only numbers checking", ->

    it "should accept only numbers when using onlyNumbers", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "ABC123"
        onlyNumbers: true
      ]

      expect(db.isValid(params)).to.be.false

    it "should pass if only numbers are supplied", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "123"
        onlyNumbers: true
      ]

      expect(db.isValid(params)).to.be.true

  describe "not numbers checking", ->

    it "should not allow numbers", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "ABC123"
        onlyLettersAndSymbols: true
      ]

      expect(db.isValid(params)).to.be.false

    it "should pass when supplied text without numbers", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "ABC;á $#%"
        onlyLettersAndSymbols: true
      ]

      expect(db.isValid(params)).to.be.true

  describe "only letters and spaces checking", ->

    it "should not pass a text with numbers", ->
      params = [
        name: "cDado"
        type: "varchar"
        value: "ABC 123 ABC"
        onlyLetters: true
      ]

      expect(db.isValid(params)).to.be.false

    it "should pass text with only letters and spaces", ->

      params = [
        name: "cDado"
        type: "varchar"
        value: "ABC ABC"
        onlyLetters: true
      ]

      expect(db.isValid(params)).to.be.true