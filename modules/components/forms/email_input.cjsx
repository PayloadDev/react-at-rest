TextInput = require './text_input'
React     = require 'react'

module.exports = class EmailInput extends React.Component

  render: ->
    <TextInput {...@props} inputType='email' />
