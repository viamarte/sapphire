#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 22/05/2013

#This is DBPM's testing spec file

#Assertion libraries
chai = require "chai"
sinon = require "sinon"
chai.should()
expect = chai.expect

#Require Tedious request module
Request = require("tedious").Request

#Testing variables
DBPM = null
server = null
testdb = null

describe "DBPM", ->
  beforeEach ->
    #Require DBPM
    DBPM = require "../lib/DBPM.js"

    #Setting test server according to config file
    server = DBPM.config.testingServer

    #Before tests, setting unexistent db to test connection errors
    testdb =
      server: "x.x.x.x"
      userName: "user"
      password: "password"
      options:
        connectTimeout: 1500

    #Fake unexistent server to test connection failure
    DBPM.config.serverList["testdb"] = testdb

  describe "Config file management", ->
    it "should throw error when config file can't be found", (done) ->
      DBPM.configFile = "foobar"
      try
        DBPM.init(null)
      catch error
        if error.toString() is "Error: foobar.json not found on root folder"
          done()

  describe "connections module", ->
    it "should throw error when server unavailable", (done) ->
      try
        DBPM.connect("dumbdb")
      catch error
        if error.toString() is "Error: dumbdb is not on list"
          done()

    it "should be able to serve connections", ->
      connection = DBPM.pool[server]["connections"][0]
      servedConnection = DBPM.getConnection server
      expect(connection).to.be.equal(servedConnection)

    it "should be able to allocate connection to the pool", ->
      instance = DBPM.connect server
      currentLength = DBPM.pool[server]["connections"].length
      DBPM.allocate instance
      newLength = DBPM.pool[server]["connections"].length
      expect(newLength).to.be.equal(currentLength+1)

  describe "refresh module", ->
    it "should be called if connections ends", (done) ->
      connection = DBPM.connect server
      connection.on "connect", ->
        spy = sinon.spy DBPM, "refresh"
        connection.close()
        if spy.called then done()

    it "should refresh instance if database connection breaks", (done) ->
      instance = DBPM.connect server
      instance.on "connect", ->
        instance = DBPM.refresh @
        if (Date.now() - instance.creationTime) < 500 then done()

  describe "retry module", ->
    it "should run when connection fails", (done) ->
      spy = sinon.spy DBPM, "retry"
      instance = DBPM.connect "testdb"
      instance.on "connect", ->
        if DBPM.retry.called
          DBPM.retry.restore()
          done()

    it "should be able to receive 3 connections retries", (done) ->
      this.timeout 5000
      instance = DBPM.connect "testdb"
      retry = DBPM.retry instance
      retry = DBPM.retry instance
      setTimeout(->
        if retry.connectionRetries is 3 then done()
      , 0)

    it "should fire error callback when it passed 3 retries", (done) ->
      this.timeout 5000
      instance = DBPM.connect "testdb", (error) ->
        done()

  describe "query execution module", ->
    it "should direct the connection to the queue after execution", (done) ->
      spy = sinon.spy DBPM, "processQueue"
      sp = "sp_tables"
      request = new Request sp, (err) ->
      request.on "requestCompleted", ->
        #console.log("RQUEST")
        setTimeout(->
          if DBPM.processQueue.called
            DBPM.processQueue.restore()
            done()
        , 50)
      DBPM.execute server, request

    it "should add to queue if no connections are available", ->
      sp = "sp_tables"
      request = new Request sp, (err) ->
      spy = sinon.spy DBPM, "addToQueue"
      connection = DBPM.pool[server]["connections"][0]
      DBPM.pool[server]["connections"][0] = undefined
      DBPM.execute server, request
      DBPM.pool[server]["connections"][0] = connection
      expect(spy.called).to.be.true

  describe "queue module", ->
    beforeEach ->
      DBPM.pool[server]["queue"] = []

    it "should be able to receive connections", ->
      sp = "sp_tables"
      request = new Request sp, (err) ->
      DBPM.addToQueue server, request
      lastIdx = DBPM.pool[server]["queue"].length
      lastItem = DBPM.pool[server]["queue"][lastIdx-1]
      expect(lastItem).to.be.equal(request)

    it "should be able to reallocate connections when queue is empty", ->
      connection = DBPM.getConnection(server)
      spy = sinon.spy DBPM, "allocate"
      DBPM.processQueue connection
      expect(spy.called).to.be.true

    it "should be able to process to the queue", (done) ->

      #Test flags
      queueEmpty = no

      sp = "sp_tables"
      request = new Request sp, (err) ->
      DBPM.addToQueue server, request
      connection = DBPM.getConnection server
      connSpy = sinon.spy connection, "callProcedure"
      DBPM.processQueue connection
      procSpy = sinon.spy DBPM, "processQueue"

      if DBPM.pool[server]["queue"][0] is undefined
        queueEmpty = yes

      setTimeout(->
        if connSpy.called and procSpy.called and queueEmpty
          done()
      , 1000)
