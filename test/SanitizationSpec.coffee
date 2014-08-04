#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 22/05/2013

#This is Sanitization's testing spec file

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
db = new Sapphire server, "sp_tables"

describe "Sanitization", ->
  describe "quote scaping", ->
    it "should escape single quotes", ->

      params = [
        {
          name: "cParam"
          type: "varchar"
          value: "' ' TEST"
        }
      ]

      safeParameters = db.sanitize params
      expect(safeParameters[0].value).to.equal("'' '' TEST")

    it "should escape double quotes", ->

      params = [
        name: "cParam"
        type: "varchar"
        value: '" " TEST'
      ]

      safeParameters = db.sanitize params
      expect(safeParameters[0].value).to.equal('"" "" TEST')

  describe "comment notation removal", ->
    it "should drop double hifens (sql comments)", ->

      params = [
        name: "cParam"
        type: "varchar"
        value: "' TEST--"
      ]

      safeParameters = db.sanitize params
      expect(safeParameters[0].value).to.equal("'' TEST-")

    it "should drop multiple hifens", ->

      params = [
        name: "cParam"
        type: "varchar"
        value: "' TEST----- TEST----"
      ]

      safeParameters = db.sanitize params
      expect(safeParameters[0].value).to.equal("'' TEST- TEST-")

  describe "trailing space removal", ->
    it "should trim trailing spaces", ->

      params = [
        name: "cParam"
        type: "varchar"
        value: " TEST "
      ]

      safeParameters = db.sanitize params
      expect(safeParameters[0].value).to.equal("TEST")

  it "should sanitize multiple problems", ->

    params = [
      name: "cParam"
      type: "varchar"
      value: "' DROP TABLE X-- "
    ]

    safeParameters = db.sanitize params
    expect(safeParameters[0].value).to.equal("'' DROP TABLE X-")
