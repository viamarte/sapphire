#Company: Via Marte - 2013
#Author: Matheus R. Kautzmann
#Creation date: 09/04/2013

#Requiring Tedious library, the base library for Sapphire.
#Tedious takes care of the TDS communication with the SQL Server DB.

Connection = require("tedious").Connection
Request = require("tedious").Request
EventEmitter = require("events").EventEmitter

#Datatypes for parameters
dataTypes = require("tedious").TYPES

#Query dependencies

#DBPM = Database Pool Manager
DBPM = require "./DBPM.js"

#Util class
Util = require "./Util.js"

#Sanitization library = Prevent SQL Injection
Sanitization = require "./Sanitization.js"

#Validation library = Validates input
Validation = require "./Validation.js"


##Sapphire's Query Class
#**Main class of Sapphire, this is the class you should use
#to interface with Sapphire.**
#
#Basically you submit a query to a server listed in the config
#file and Sapphire does the rest.
#
#@note Sapphire only supports SQL Server stored procedures.
#Sapphire won't support direct SQL queries to the server.
#
#As you can see Query extends Node.JS EventEmitter so we use
#events to report the results of the query as well as errors.
#
#This way queries made against Sapphire won't block your code,
#you can even do other things while your request is being processed
#by the database.
#
#Most uses of Sapphire will use just two methods, the Sapphire constructor
#to build the query and the execute method to actually execute it.
#
# ##Executing a query
#**In order to execute a query you must follow 3 steps:**
#
#- 1) Call the constructor and assign the new instance to a variable;
#- 2) Listen to the results and databaseError events;
#- 3) Call the execute method on your instance to kickoff the request.
#
# @method #on("results", callback)
#   Event that should be listened to get the query results.
#   @param [String] "results" "results" event
#   @param [Function] callback function to call when event gets called,
#     callback has three arguments: resultArray, server and sp.
#   @since 1.0.0
#
# @method #on("databaseError", callback)
#   Event that should be listened to get in case of error.
#   @param [String] "databaseError" "databaseError" event.
#   @param [Function] callback function to call when event gets called,
#     callback has three arguments: error, server and sp.
#   @since 1.0.0
#
# @method #on("parameterNotDefined", callback)
#   Event that will be fired when value parameter is undefined
#   @param [String] "parameterNotDefined" "parameterNotDefined" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
#
# @method #on("invalidDataType", callback)
#   Event that will be fired when the type isn't supported.
#   @param [String] "invalidDataType" "invalidDataType" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @see https://vmarte.co/uKYV Sapphire's supported types.
#   @since 1.0.0
#
# @method #on("dataTypeMismatch", callback)
#   Event that will be fired when the given type is incorrect.
#   @param [String] "dataTypeMismatch" "dataTypeMismatch" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
#
# @method #on("sizeOutOfBounds", callback)
#   Event that will be fired when the given value isn't between
#   minValue and maxValue.
#   @param [String] "sizeOutOfBounds" "sizeOutOfBounds" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
#
# @method #on("notOnlyNumbers", callback)
#   Event that will be fired when the given value isn't only
#   numbers with the isOnlyNumbers flag set.
#   @param [String] "notOnlyNumbers" "notOnlyNumbers" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
#
# @method #on("notOnlyLetters", callback)
#   Event that will be fired when the given value isn't only
#   letters and spaces with the notOnlyLetters flag set.
#   @param [String] "notOnlyLetters" "notOnlyLetters" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
#
# @method #on("notOnlyLettersAndSymbols", callback)
#   Event that will be fired when the given value contains
#   numbers with the isOnlyLettersAndSymbols flag set.
#   @param [String] "notOnlyLettersAndSymbols"
#     "notOnlyLettersAndSymbols" event.
#   @param [Function] callback function to call when event gets called,
#     callback has one argument: parameter.
#   @since 1.0.0
class Sapphire extends EventEmitter

  #Parameters types, supported SQL data types
  @parametersTypes:
    varchar: dataTypes.VarChar
    text: dataTypes.Text
    char: dataTypes.VarChar
    nvarchar: dataTypes.NVarChar
    ntext: dataTypes.NVarChar
    nchar: dataTypes.NVarChar
    bigint: dataTypes.VarChar
    int: dataTypes.Int
    smallint: dataTypes.SmallInt
    tinyint: dataTypes.TinyInt
    bit: dataTypes.Bit
    datetime: dataTypes.DateTime
    smalldatetime: dataTypes.SmallDateTime
    date: dataTypes.DateTime
    time: dataTypes.DateTime
    float: dataTypes.Float
    numeric: dataTypes.Float
    money: dataTypes.Float
    uniqueidentifier: dataTypes.VarChar

  #Prepared Query = Filled when a new object is instantiated
  pq: null

  #Methods

  #Constructor for Sapphire. Prepate the query to be executed.
  #
  #Responsible for preparing stored procedures to be executed later.
  #
  #You should always create your query instantiating a new Query.
  #
  #Instantiating a new Sapphire is the first thing you need to do.
  #
  #@example Creating a query with CoffeeScript
  #   p1 =
  #     name: "foo"
  #     type: "varchar"
  #     value: "bar"
  #   p2 =
  #     name: "qux"
  #     type: "int"
  #     value: 2
  #   query = new Sapphire "srv", "stored_procedure_name", [p1, p2]
  #
  #@example Creating a query with JavaScript
  #   var p1 = {
  #     name: "foo",
  #     type: "varchar",
  #     value: "bar"
  #   };
  #   var p2 = {
  #     name: "qux",
  #     type: "int",
  #     value: 2
  #   };
  #   var query = new Sapphire("srv", "stored_procedure_name", [p1, p2]);
  #
  #@param [String] server server alias as listed in config file.
  #@param [String] sp sp name that you are calling.
  #@param [Array<Object>] parameters array of objects that acts as parameters.
  #
  #@since 1.0.0
  #
  constructor: (server, sp, parameters) ->
    #Preparing query for execution with execute method
    @prepare server || null, sp || null, parameters || null

  #Check if the data type supplied exists in Sapphire.
  #
  #@param [String] type data type of the parameter supplied.
  #
  #@since 1.0.0
  #
  hasDataType: (type) ->
    for item in Object.keys Sapphire.parametersTypes
      if type == item
        return yes
    return no

  #Internal method that prepare the query to be executed.
  #**You don't need to call this method directly,
  #just create a new Query instance and you should be good to go.**
  #
  #@param [String] server server alias as listed in config file.
  #@param [String] sp sp name that will be called.
  #@param [Array<Object>] parameters array of objects that acts as parameters.
  #
  #@since 1.0.0
  #
  prepare: (server, sp, parameters) ->
    @pq =
      server: server
      sp: sp
      parameters: parameters

  #Internal method that parses parameters, validates and sanitize them,
  #then passes the query to the execution process on DBPM.
  #**You don't need to call this method directly,
  #just create a new Query instance and you should be good to go.**
  #
  #@param [String] server server alias as listed in config file.
  #@param [String] sp sp name that will be called.
  #@param [Array<Object>] parameters array of objects that acts as parameters.
  #
  #@since 1.0.0
  #
  query: (server, sp, parameters) ->

    resultArray = []

    rowIndex = 0

    if DBPM.hasServerAvailable server
      if parameters?
        sanitizedParameters = @sanitize parameters
      else
        sanitizedParameters = []

      if @isValid sanitizedParameters
        request = new Request sp, (err) =>
          if err?
            @emit "databaseError", err, server, sp
          else
            @emit "results", resultArray, server, sp

        for parameter in sanitizedParameters
          request.addParameter(parameter.name,
           Sapphire.parametersTypes[parameter.type],
            parameter.value)

        request.on "row", (columns) ->
          returnedValues = {}
          for column in columns
            returnedValues[column.metadata.colName] = column.value
          resultArray[rowIndex] = returnedValues
          rowIndex++

        DBPM.execute server, request
      else
        @emit "databaseError", "Invalid parameter"
    else
      @emit "serverNotOnList", server

  #This method will send your request to the DBPM.
  #
  #@note Only call this method when you already set the listeners
  #
  #It is important to listen to the results and databaseError events,
  #otherwise you won't now the result of the query.
  #
  #@example Executing query with CoffeeScript
  #   p1 =
  #     name: "foo"
  #     type: "varchar"
  #     value: "bar"
  #   p2 =
  #     name: "qux"
  #     type: "int"
  #     value: 2
  #   query = new Sapphire "srv", "stored_procedure_name", [p1, p2]
  #   query.on "results", (results) ->
  #     console.log results
  #   query.on "databaseError", (error) ->
  #     console.log "Oops, we got an error: #{error}"
  #   query.execute() # Now that we set the events, we can execute
  #
  #@example Executing query with JavaScript
  #   var p1 = {
  #     name: "foo",
  #     type: "varchar",
  #     value: "bar"
  #   };
  #   var p2 = {
  #     name: "qux",
  #     type: "int",
  #     value: 2
  #   };
  #   var query = new Sapphire("srv", "stored_procedure_name", [p1, p2]);
  #   query.on("results", function(results){
  #     console.log(results);
  #   });
  #   query.on("databaseError", function(error){
  #     console.log("Oops, we got an error:" + error);
  #   });
  #   query.execute(); // Now that we set the events we can execute
  #
  #@since 1.0.0
  #
  execute: ->
    #Executing query:

    #1) Getting available connection
    #2) Validating and sanitizing parameters
    #3) Execute Stored Procedure call
    #4) Emit event with the results
    #console.log @pq
    if @pq.server? and @pq.sp?
      @query @pq.server, @pq.sp, @pq.parameters

  #Utility method to the query method that sanitize parameters.
  #
  #It actually interfaces with the Sanitization class to do that.
  #
  #@param [Array<Object>] parameters array of parameters objects.
  #
  #@since 1.0.0
  #
  sanitize: (parameters) ->
    newParameters = parameters
    for parameter in parameters
      if @hasDataType parameter.type
        if Util.typeOf(parameter.value) is "string"
          newValue = Sanitization.trim parameter.value
          newValue = Sanitization.escapeQuotes newValue
          newValue = Sanitization.dropComments newValue
          newParameters[_i].value = newValue
    return newParameters

  #Utility method to the query method that validates parameters.
  #
  #It actually interfaces with the Validation class to do that.
  #
  #@param [Array<Object>] parameters array of parameters objects.
  #
  #@since 1.0.0
  #
  isValid: (parameters) ->
    for parameter in parameters
      currentValue = parameter.value
      currentType = parameter.type
      max = parameter.maxValue
      min = parameter.minValue

      unless currentValue?
        @emit "parameterNotDefined", parameter
        return no

      unless @hasDataType currentType
        @emit "invalidDataType", parameter
        return no
      
      unless Validation.isTypeOK currentType, currentValue
        @emit "dataTypeMismatch", parameter
        return no

      unless Validation.isSizeOK currentType, currentValue, min, max
        @emit "sizeOutOfBounds", parameter
        return no

      if parameter.onlyNumbers
        unless Validation.isOnlyNumbers currentValue
          @emit "notOnlyNumbers", parameter
          return no

      if parameter.onlyLettersAndSymbols
        unless Validation.isOnlyLettersAndSymbols currentValue
          @emit "notOnlyLettersAndSymbols", parameter
          return no

      if parameter.onlyLetters
        unless Validation.isOnlyLetters currentValue
          @emit "notOnlyLetters", parameter
          return no
    return yes

#Exporting module
module.exports = Sapphire
