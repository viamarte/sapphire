#Company: Via Marte - 2013
#Author: Matheus R. Kautzmann
#Date: 22/05/2013

##Sapphire's Sanitization Class
#Responsible for sanitizing string input to the database
#This class are automatically used by Sapphire, so you don't need to
#use it directly, see Sapphire's README file for examples.
#**All the methods in this class are private.**
#@author Matheus R. Kautzmann
#@copyright VIA MARTE 2013
class Sanitization

  #Escape quotes present in the given parameter.
  #This helps prevent SQL Injection by disabling misquotes.
  #
  #@example Escaping quotes with CoffeeScript
  #   value = "'TEST"
  #   Sanitization.escapeQuotes value # Return ''TEST
  #
  #@example Escaping quotes with JavaScript
  #   var value = "'TEST";
  #   Sanitization.escapeQuotes(value); // Return ''TEST
  #
  #@param [String] value string that will be passed to the database.
  #
  #@return [String] string sanitized, i.e. with quotes in order.
  #
  #@private
  #
  #@since 1.0.0
  #
  @escapeQuotes: (value) ->
    newValue = value
    newValue = value.replace /'+/g, "''"
    newValue = newValue.replace /"+/g, '""'

  #Drop SQL Server comments.
  #Useful to prevent SQL Injections in SQL Server.
  #
  #It transform any combination of two hifens in just one,
  #eliminating comment notation in the given string.
  #
  #@example Dropping comments with CoffeeScript
  #   value = "TEST--"
  #   Sanitization.dropComments value # Return TEST-
  #
  #@example Dropping comments with JavaScript
  #   var value = "TEST--";
  #   Sanitization.dropComments(value); // Return TEST-
  #
  #@param [String] value string that will be passed to the database.
  #
  #@return [String] string sanitized, i.e. with comments dropped.
  #
  #@private
  #
  #@since 1.0.0
  #
  @dropComments: (value) ->
    value.replace /--+/g, "-"

  #Trim the given value, eliminating trailing spaces.
  #
  #@example Trimming with CoffeeScript
  #   value = " TEST "
  #   Sanitization.trim value # Return TEST
  #
  #@example Trimming with JavaScript
  #   var value = " TEST ";
  #   Sanitization.trim(value); // Return TEST
  #
  #@param [String] value string that will be passed to the database.
  #
  #@return [String] string without trailing spaces.
  #
  #@private
  #
  #@since 1.0.0
  #
  @trim: (value) ->
    value.trim()

module.exports = Sanitization