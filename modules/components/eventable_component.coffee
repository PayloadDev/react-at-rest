Events = require '../../vendor/events'
React  = require 'react'
_      = require 'lodash'

module.exports = class EventableComponent extends React.Component

  componentWillUnmount: ->
    @stopListening()


_.extend(EventableComponent::, Events)
