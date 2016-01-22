TextInput = require './text_input'
React     = require 'react'

module.exports = class NumberInput extends React.Component

  render: ->
    <TextInput {...@props} inputType='number' />
