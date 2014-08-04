# Via Marte - 2013
# Author: Matheus R. Kautzmann
# Date: 10/05/2013

#Requiring Util class
Util = require("./Util.js")

##Sapphire's Validation Class
#This is a utility class that provides tools for validating data.
#**This class is used by Sapphire, so don't call it directly.**
#@author Matheus Kautzmann
#@copyright VIA MARTE 2013
class Validation

  #CONSTANT = SQL Server Limitations
  @TYPES = require "../limits_data/limits.json"

  #Method that verifies the size and limits for the value passed in
  #the query based on the type of the value and the bounds given by
  #the user.
  #
  #@example Verifying size with CoffeeScript
  #   value = "TEST"
  #   minValue = 2
  #   maxValue = 4
  #   type = "int"
  #   Validation.isSizeOK type, value, minValue, maxValue #It is true
  #
  #@example Verifying size with JavaScript
  #   var value = "TEST";
  #   var minValue = 2;
  #   var maxValue = 4;
  #   var type = "int";
  #   Validation.isSizeOK(type, value, minValue, maxValue); //It is true
  #
  #@param [String] type data type of the value in SQL Server
  #@param [Object] value value of the data, in any type.
  #@param [Object] minValue minimum value that the value can assume.
  #@param [Object] maxValue maximum value that the value can assume.
  #
  #@return [Boolean] is size ok?
  #
  #@private
  #
  #@since 1.0.0
  #
  @isSizeOK: (type, value, minValue, maxValue) ->
    if minValue?
      if minValue.getTime
        minValue = minValue.getTime()

    if maxValue?
      if maxValue.getTime
        maxValue = maxValue.getTime()

    for item in Validation.TYPES
      if type is item.name
        if !minValue or minValue < item.min then minValue = item.min
        if !maxValue or maxValue > item.max then maxValue = item.max
        return Validation.validateSize value, minValue, maxValue

    return yes

  #A companion method to isSizeOK() that actually verifies if
  #the given value is between minValue and maxValue.
  #
  #@example Validating size with CoffeeScript
  #   value = "TEST"
  #   minValue = 2
  #   maxValue = 4
  #   Validation.validateSize value, minValue, maxValue #It is true
  #
  #@example Validating size with JavaScript
  #   var value = "TEST";
  #   var minValue = 2;
  #   var maxValue = 4;
  #   Validation.validateSize(value, minValue, maxValue); //It is true
  #
  #@param [Object] value value given by the user
  #@param [Object] minValue minimum value that the value can assume.
  #@param [Object] maxValue maximum value that the value can assume.
  #
  #@return [Boolean] is size within bounds?
  #
  #@private
  #
  #@since 1.0.0
  #
  @validateSize: (value, minValue, maxValue) ->
    if Util.typeOf(value) is "string"
      value = value.length
    if maxValue >= value >= minValue then yes else no

  #Method to check if given SQL data type matches the type of
  #the variable declared in JavaScript.
  #
  #@example Validating type with CoffeeScript
  #   value = "TEST"
  #   type = "varchar"
  #   Validation.isTypeOK type, value #It's true
  #
  #@example Validating type with JavaScript
  #   var value = "TEST";
  #   var type = "varchar";
  #   Validation.isTypeOK(type, value); //It's true
  #
  #@param [String] type data type of the value in SQL Server
  #@param [Object] value value given by the user.
  #
  #@return [Boolean] is type correct?
  #
  #@private
  #
  #@since 1.0.0
  #
  @isTypeOK: (type, value) ->
    if Util.typeOf(value) is "string"
      correctTypes = [
        "varchar"
        "char"
        "text"
        "ntext"
        "nvarchar"
        "nchar"
        "uniqueidentifier"
      ]
      return yes for item in correctTypes when item == type

    if Util.typeOf(value) is "number"
      correctTypes = [
        "int"
        "tinyint"
        "smallint"
        "bigint"
        "float"
        "money"
        "numeric"
      ]
      return yes for item in correctTypes when item == type
      
    if Util.typeOf(value) is "boolean"
      correctTypes = [
        "bit"
      ]
      return yes for item in correctTypes when item == type

    if Util.typeOf(value) is "date"
      correctTypes = [
        "date"
        "datetime"
        "smalldatetime"
        "time"
      ]
      return yes for item in correctTypes when item == type

    return no

  # EXTRA VALIDATION, OPTIONAL

  #Used if isOnlyNumbers flag is set.
  #
  #Checks if the string passed has only numbers.
  #
  #@example Check if isOnlyNumbers in CoffeeScript
  #   value = "1234"
  #   Validation.isOnlyNumbers value # It is true
  #
  #@example Check if isOnlyNumbers in JavaScript
  #   var value = "1234";
  #   Validation.isOnlyNumbers(value); // It is true
  #
  #@param [String] value value to check if isOnlyNumbers.
  #
  #@return [Boolean] is the value only numbers?
  #
  #@private
  #
  #@since 1.0.0
  #
  @isOnlyNumbers: (value) ->
    /^[0-9]+$/.test value

  #Used if isOnlyLettersAndSymbols flag is set.
  #
  #Checks if the string passed has only letters and symbols.
  #In other words it checks if the string doesn't contain numbers.
  #
  #@example Check if isOnlyLettersAndSymbols in CoffeeScript
  #   value = "ABC$ABC"
  #   Validation.isOnlyLettersAndSymbols value # It is true
  #
  #@example Check if isOnlyLettersAndSymbols in JavaScript
  #   var value = "ABC$ABC";
  #   Validation.isOnlyLettersAndSymbols(value); // It is true
  #
  #@param [String] value value to check if isOnlyLettersAndSymbols.
  #
  #@return [Boolean] does the value contains only letters and symbols?
  #
  #@private
  #
  #@since 1.0.0
  #
  @isOnlyLettersAndSymbols: (value) ->
    /^[^0-9]+$/.test value

  #Used if isOnlyLetters flag is set.
  #
  #Checks if the string passed has only letters and spaces.
  #In this case the string cannot contain symbols.
  #
  #@example Check if isOnlyLetters in CoffeeScript
  #   value = "ABC"
  #   Validation.isOnlyLetters value # It is true
  #
  #@example Check if isOnlyLettersAndSymbols in JavaScript
  #   var value = "ABC";
  #   Validation.isOnlyLetters(value); // It is true
  #
  #@param [String] value value to check if isOnlyLettersAndSymbols.
  #
  #@return [Boolean] does the value contains only letters and symbols?
  #
  #@private
  #
  #@since 1.0.0
  #
  @isOnlyLetters: (value) ->
    /^[a-z\sA-Z]+$/.test value

module.exports = Validation