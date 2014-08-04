#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 11/07/2013

#Via Marte's utility class
#Created to fix some of the JavaScript flaws, so we can
#use features safely from our libraries.
#This is still on development, we add functions based on demand.
class Util

  #Utility method that fixes typeof
  #The idea is to use this method in place of typeof.
  #
  #@param [Object] object object that will be tested.
  #
  #@return [String] type of given object
  #
  #@since 1.0.0
  #
  #@see http://bonsaiden.github.io/JavaScript-Garden/#types.typeof
  #
  @typeOf: (object) ->
    classTypes =
      "[object String]": "string"
      "[object Array]": "array"
      "[object Null]": "null"
      "[object Number]": "number"
      "[object RegExp]": "regexp"
      "[object Date]": "date"
      "[object Boolean]": "boolean"
      "[object Function]": "function"
      "[object Error]": "error"
      "[object Undefined]": "undefined"

    #Using object's prototype to see what type is object
    typeString = Object::toString.call(object)
    return classTypes[typeString] or "object"

module.exports = Util