classNames = require 'classnames'
React      = require 'react'

module.exports = class FieldHint extends React.Component

  @displayName = 'FieldHint'

  @propTypes =
    className: React.PropTypes.string
    hint:      React.PropTypes.oneOfType([
                React.PropTypes.string
                React.PropTypes.object
              ])

  render: ->
    return null unless @props.hint?

    <span className={classNames 'help-block', @props.className}>
      {@props.hint}
    </span>
