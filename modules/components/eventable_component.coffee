Events = require '../../vendor/events'
React  = require 'react'
_ =
  extend: require 'lodash/object/extend'


module.exports = class EventableComponent extends React.Component

  componentWillUnmount: ->
    @stopListening()


_.extend(EventableComponent::, Events)
