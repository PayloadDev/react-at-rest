RestFormElement = require '../rest_form_element'
TextInput       = require './text_input'

PropTypes = require 'prop-types'
React     = require 'react'

module.exports = class PasswordInput extends React.Component

  @propTypes = RestFormElement.propTypes

  render: ->
    <TextInput {...@props} inputType='password' />
