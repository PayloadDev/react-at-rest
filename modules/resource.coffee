Utils = require './utils'

module.exports = class Resource

  constructor: (attributes, policy) ->

    # assign all the attributes to this object
    for key,val of attributes
      do (key) =>
        Object.defineProperty @, key,
          value:      attributes[key]
          enumerable: true

    # create non-enumerable policy methods
    for key,val of policy
      do (key, val) =>
        unless key[-3..] is '_id' then Object.defineProperty @, "can#{Utils.capitalize key}",
          enumerable: false
          value: ->
            val ? false


