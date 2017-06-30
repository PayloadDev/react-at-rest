TextInput = require './text_input'

PropTypes = require 'prop-types'
React     = require 'react'

module.exports = class NumberInput extends React.Component

  render: ->
    <TextInput {...@props} inputType='number' />
