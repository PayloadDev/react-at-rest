React      = require 'react'
classNames = require 'classnames'

module.exports = class FieldWrapper extends React.Component

  @displayName = 'FieldWrapper'

  @propTypes =
    className: React.PropTypes.string
    errors:    React.PropTypes.array
    formGroup: React.PropTypes.bool

  @defaultProps =
    formGroup: true


  render: ->
    className = classNames @props.className,
      'form-group': @props.formGroup
      'has-error':  @props.errors?

    <div className={className}>
      {@props.children}
    </div>