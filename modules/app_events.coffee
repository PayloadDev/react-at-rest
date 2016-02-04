_ =
  extend: require 'lodash/object/extend'
Events = require '../vendor/events'


class AppEvents

  constructor: ->
    # welp


_.extend(AppEvents::, Events)
module.exports = new AppEvents()
