classNames = require 'classnames'
PropTypes  = require 'prop-types'
React      = require 'react'

module.exports = class FieldWrapper extends React.Component

  @displayName = 'FieldWrapper'

  @propTypes =
    className: PropTypes.string
    errors:    PropTypes.array
    formGroup: PropTypes.bool
    style:     PropTypes.object

  @defaultProps =
    formGroup: true


  render: ->
    className = classNames @props.className,
      'form-group': @props.formGroup
      'has-error':  @props.errors?

    <div className={className} style={@props.style}>
      {@props.children}
    </div>
