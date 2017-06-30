TextInput = require './text_input'

PropTypes = require 'prop-types'
React     = require 'react'

module.exports = class EmailInput extends React.Component

  render: ->
    <TextInput {...@props} inputType='email' />
