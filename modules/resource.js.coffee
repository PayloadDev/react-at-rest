Utils = require './utils'

module.exports = class Resource

  constructor: (@attributes, @policy={}) ->
    for key,val of @attributes
      do (key) =>
        Object.defineProperty @, key,
          get: -> @attributes[key]
          set: (val) -> @attributes[key] = val

    for key,val of @policy
      do (key, val) =>
        @["can#{Utils.capitalize key}"] = ->
          val ? false
