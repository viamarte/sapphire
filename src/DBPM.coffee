#Company: Via Marte - 2013
#Author: Matheus R. Kautzmann
#Date: 22/05/2013

#Requiring connection
Connection = require("tedious").Connection

#Require Util
Util = require "./Util.js"

##Sapphire's Database Pool Manager Class
#Responsible for controling the database connection pool and
#connection requests, it also proxy the requests to the database.
#This is a private class that you shouldn't call directly.
#
#**All the method in this class are private and should not be called directly.**
#@author Matheus R. Kautzmann
#@copyright VIA MARTE 2013
class DBPM

  #Indicates current status of DBPM
  @ready: no

  #Connection initialization counter
  @initCount: -1

  #Config filename that Sapphire will use to configure itself
  @configFile = "sconfig"

  #Prevent problems when using connections before pool ready.
  @allocateControl: on

  #The pool holds the connection pool and the queue for each server
  @pool: {}

  #Internal method that initializes the database connection pool.
  #
  #@param [Function] callback function to call when the init finishes.
  #
  #@example How to call init with function callback in CoffeeScript
  #   callback = ->
  #     console.log "Database ready to use!"
  #   DBPM.init callback
  #
  #@example How to call init with function callback in JavaScript
  #   function callback() {
  #     console.log("Database ready to use!");
  #   }
  #   DBPM.init(callback);
  #
  #@private
  #
  #@since 1.0.0
  #
  @init: (callback) ->
    try
      DBPM.config = require "#{process.cwd()}/#{@configFile}.json"
    catch error
      throw new Error "#{@configFile}.json not found on root folder"

    for server of DBPM.config.serverList

      #Setting application name
      DBPM.config.serverList[server].options.appName = "Sapphire"

      #Create server node
      DBPM.pool[server] = {}

      #Defining connection and queue arrays
      DBPM.pool[server].connections = []
      DBPM.pool[server].queue = []

    if callback?
      #Fills the pool with connections
      DBPM.initializePool callback

  #Method to check if server requested appears on the server's list.
  #
  #@example Check if server exists in CoffeeScript
  #   if DBPM.hasServerAvailable "serverName" then "YEAH!" else "NO..."
  #
  #@example Check if server exists in JavaScript
  #   if DBPM.hasServerAvailable(serverName) {
  #     return "YEAH!"
  #   }
  #   else {
  #     return "NO..."
  #   }
  #
  #@param [String] server server alias as specified in the config file
  #
  #@return [Boolean] server availability
  #
  #@private
  #
  #@since 1.0.0
  #
  @hasServerAvailable: (server) ->
    if DBPM.config.serverList[server] then yes else no

  #Method called automatically by DBPM.init() that iterates over
  #the connection array to connect them.
  #
  #@example Initializing Pool with CoffeeScript
  #   callback = ->
  #     console.log "Database ready to use!"
  #   DBPM.initializePool callback
  #
  #@example How to call init with function callback in JavaScript
  #   function callback() {
  #     console.log("Database ready to use!");
  #   }
  #   DBPM.initializePool(callback);
  #
  #@param [Function] callback function to call when process complete
  #
  #@private
  #
  #@since 1.0.0
  #
  @initializePool: (callback) ->
    for server of DBPM.config.serverList
      i = 0
      while i < DBPM.config.maxConnections
        DBPM.connect server
        DBPM.initCount++
        i++

    DBPM.initCount = 0
    callback.apply()

  #The connect method, you should never have to call it.
  #It is an internal method.
  #This method cares for each the database connection.
  #
  #@example Creating a connection to a server with CoffeeScript
  #   server = "serverName" #Some server listed on the config file
  #   DBPM.connect server
  #
  #@example Creating a connection to a server with JavaScript
  #   var server = "serverName"; //Some server listed on config file
  #   DBPM.connect(server);
  #
  #@param [String] server server to which the connection will be open
  #@param [int] retries optional parameter, current number of retries
  #@param [Function] serverDownCallback callback when number of retries pass 3
  #
  #@return [Connection] the connection created
  #
  #@throw Error when the requested server is not on the serverList
  #
  #@private
  #
  #@since 1.0.0
  #
  @connect: (server, serverDownCallback, retries) ->

    connection = null

    if DBPM.hasServerAvailable server

      connection = new Connection DBPM
      .config.serverList[server]

      connection.poolServer = server

      connection.connectionRetries = retries || 0

      connection.creationTime = Date.now()

      #Event emitted when connected or encountered error
      connection.once "connect", (err) ->
        if err?
          #Retry the connection in case of error
          DBPM.retry connection, serverDownCallback
        else
          #Allocate the connection to the pool if successful
          DBPM.allocate connection

          #Connection life time runs out, refresh connection
          connection.once "end", ->
            DBPM.refresh connection
    else
      throw new Error "#{server} is not on list"

    return connection

  #This method task is to allocate connections to the
  #connection pool. Developers shouldn't call this method manually.
  #
  #@example Allocating a connection with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   connection = new Connection DBPM
  #   .config.serverList[server]
  #   connection.poolServer = server
  #   DBPM.allocate connection
  #
  #@example Allocating a connection with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var connection = new Connection(DBPM
  #   .config.serverList[server]);
  #   connection.poolServer = server;
  #   DBPM.allocate(connection);
  #
  #@param [Connection] connection connection that will be allocated
  #
  #@private
  #
  #@since 1.0.0
  #
  @allocate: (connection) ->
    id = DBPM.pool[connection.poolServer].connections.length
    if DBPM.allocateControl and DBPM.config.maxConnections == id
      DBPM.allocateControl = off
      DBPM.processQueue connection
    else
      connection.poolId = id
      DBPM.pool[connection.poolServer].connections.push connection

  #Method to refresh the connections in case of failure.
  #Common cases are the SQL Server connection timeouts.
  #
  #@example Refreshing a connection with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   connection = DBPM.connect server
  #   DBPM.refresh connection
  #
  #@example Refreshing a connection with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var connection = DBPM.connect(server);
  #   DBPM.refresh(connection);
  #
  #@param [Connection] connection connection that will be refreshed
  #
  #@private
  #
  #@since 1.0.0
  #
  @refresh: (connection) ->
    DBPM.pool[connection.poolServer].connections
    .splice connection.poolId, 1
    DBPM.connect connection.poolServer

  #This method will be called when the server doesn't answer to a
  #connection request.
  #It will try 3 times before throwing a server unavailable error.
  #
  #@example Retrying a connection with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   connection = DBPM.connect server
  #   DBPM.retry connection
  #
  #@example Retrying a connection with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var connection = DBPM.connect(server);
  #   DBPM.retry(connection);
  #
  #@param [Connection] connection problematic connection
  #@param [Function] errorCallback callback to call when retry count pass 3
  #
  #@return [Connection] connection passed through.
  #
  #@private
  #
  #@since 1.0.0
  #
  @retry: (connection, errorCallback) ->
    i = connection
    if i.connectionRetries <= 3
      i.connectionRetries++
      setTimeout ->
        return DBPM.connect i.poolServer, errorCallback, i.connectionRetries
      , 1000
    else
      if Util.typeOf(errorCallback) is "function"
        errorCallback.apply @, ["#{i.poolServer} server unavailable"]
    return i

  #Responsible for getting a connection to execute a requested query.
  #
  #Again, this method is part of the internal framework and should not
  #be called directly.
  #
  #@example Getting a connection with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   DBPM.getConnection server
  #
  #@example Getting a connection with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   DBPM.getConnection(server);
  #
  #@param [String] server server alias as informed on config file.
  #
  #@return [Connection] connection available to receive queries.
  #
  #@private
  #
  #@since 1.0.0
  #
  @getConnection: (server) ->
    #Gets first connection
    firstConnection = DBPM.pool[server].connections[0]

  #Method that adds requests to the queue.
  #
  #@example Adding a connection to the queue with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   request = new Request sp, (err) ->
  #   DBPM.addToQueue server, request
  #
  #@example Adding a connection to the queue with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var request = new Request(sp, function(err){});
  #   DBPM.addToQueue(server, request);
  #
  #@param [String] server server alias as informed on config file.
  #@param [Request] request request to be added to the queue.
  #
  #@return [Object] current queue of requests.
  #
  #@private
  #
  #@since 1.0.0
  #
  @addToQueue: (server, request) ->
    DBPM.pool[server].queue.push request

  #Method that process the queue, ran directly by Sapphire.
  #
  #@example Process the queue with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   connection = DBPM.connect server
  #   DBPM.processQueue connection
  #
  #@example Process the queue with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var connection = DBPM.connect(server);
  #   DBPM.processQueue(connection);
  #
  #@param [Connection] connection that will help process the queue.
  #
  #@private
  #
  #@since 1.0.0
  #
  @processQueue: (connection) ->

    server = connection.poolServer

    nextRequest = DBPM.pool[server].queue[0]

    if nextRequest isnt undefined
      DBPM.pool[server].queue.splice 0, 1
      nextRequest.once "requestCompleted", ->
        #console.log "Emptying queue"
        DBPM.processQueue connection

      connection.callProcedure nextRequest
    else
      #console.log "Queue empty"

      #Queue empty, reallocate connection
      DBPM.allocate connection

  #Method that executes requests, it verifies if the connection exists
  #in the pool of available connections and delegate a request to it.
  #
  #In case of unavailable connection it adds the request to the queue.
  #
  #@example Execute a request with CoffeeScript
  #   server = "testserver" # Some server listed on config file
  #   connection = DBPM.connect server
  #   DBPM.processQueue connection
  #
  #@example Execute a request with JavaScript
  #   var server = "testserver"; // Some server listed on config file
  #   var connection = DBPM.connect(server);
  #   DBPM.processQueue(connection);
  #
  #@param [Connection] connection that will help process the queue.
  #
  #@private
  #
  #@since 1.0.0
  #
  @execute: (server, request) ->
    #Gets a database connection with the server needed
    connection = DBPM.getConnection server

    #If Object is empty then we have no connections.
    #So we put the request on the queue
    #console.log connection
    if connection is undefined or !DBPM.pool
      DBPM.addToQueue server, request
    else
      #Connection in use, remove it from stack
      DBPM.pool[connection.poolServer].connections
      .splice @poolId, 1

      #Using Tedious low-level event here because
      #we are in another scope.
      request.once "requestCompleted", ->
        #Connection now available, process queue
        DBPM.processQueue connection

      connection.callProcedure request

    return connection

#Auto initializes Sapphire
DBPM.init ->
  DBPM.ready = yes

module.exports = DBPM
