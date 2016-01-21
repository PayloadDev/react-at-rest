React = require 'react'

module.exports = class FieldErrors extends React.Component

  @displayName = 'FieldErrors'

  @propTypes =
    errors: React.PropTypes.array

  render: ->
    return null unless @props.errors?
    <span className="help-block field-error">{@props.errors.join ', '}</span>
