React      = require 'react'
classNames = require 'classnames'

module.exports = class FieldWrapper extends React.Component

  @displayName = 'FieldWrapper'

  @propTypes =
    errors: React.PropTypes.array

  render: ->
    className = classNames @props.className, 'form-group',
      'has-error': @props.errors?

    <div className={className}>
      {@props.children}
    </div>

