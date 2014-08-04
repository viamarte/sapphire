#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 11/07/2013

#This is Util's testing spec file

#Assertion libraries
chai = require "chai"
chai.should()
expect = chai.expect

#Util class
Util = require "../lib/Util.js"

describe "Util", ->

  describe "type of checking", ->

    it "should detect string type with short declaration", ->
      string = "TEST"
      expect(Util.typeOf(string)).to.be.equal("string")

    it "should detect string type with class instantiation", ->
      string = new String("TEST")
      expect(Util.typeOf(string)).to.be.equal("string")

    it "should detect array type with short declaration", ->
      array = []
      expect(Util.typeOf(array)).to.be.equal("array")

    it "should detect array type with class instantiation", ->
      array = new Array()
      expect(Util.typeOf(array)).to.be.equal("array")

    it "should detect number type with shot declaration", ->
      number = 1.5
      expect(Util.typeOf(number)).to.be.equal("number")

    it "should detect number type with class instantiation", ->
      number = new Number(1.5)
      expect(Util.typeOf(number)).to.be.equal("number")

    it "should detect null", ->
      _null = null
      expect(Util.typeOf(_null)).to.be.equal("null")

    it "should detect regexp with short declaration", ->
      regexp = /abc/
      expect(Util.typeOf(regexp)).to.be.equal("regexp")

    it "should detect regexp with class instantiation", ->
      regexp = new RegExp("abc")
      expect(Util.typeOf(regexp)).to.be.equal("regexp")

    it "should detect boolean with short declaration", ->
      boolean = true
      expect(Util.typeOf(boolean)).to.be.equal("boolean")

    it "should detect boolean with class instantiation", ->
      boolean = true
      expect(Util.typeOf(boolean)).to.be.equal("boolean")

    it "should detect dates", ->
      date = new Date("July 11, 2013 09:08")
      expect(Util.typeOf(date)).to.be.equal("date")

    it "should detect errors", ->
      error = new Error()
      expect(Util.typeOf(error)).to.be.equal("error")

    it "should detect functions", ->
      _function = new Function()
      expect(Util.typeOf(_function)).to.be.equal("function")

    it "should detect undefined", ->
      _undefined = undefined
      expect(Util.typeOf(_undefined)).to.be.equal("undefined")

    it "should detect objects with short declaration", ->
      _object = {}
      expect(Util.typeOf(_object)).to.be.equal("object")

    it "should detect objects with class instantiation", ->
      _object = new Object()
      expect(Util.typeOf(_object)).to.be.equal("object")
      
