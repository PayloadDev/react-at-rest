PropTypes = require 'prop-types'
React     = require 'react'

module.exports = class FieldErrors extends React.Component

  @displayName = 'FieldErrors'

  @propTypes =
    errors: PropTypes.array

  render: ->
    return null unless @props.errors?
    <span className="help-block field-error">{@props.errors.join ', '}</span>
