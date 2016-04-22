React = require 'react'

module.exports = class FieldHint extends React.Component

  @displayName = 'FieldHint'

  @propTypes =
    hint: React.PropTypes.oneOfType([
            React.PropTypes.string
            React.PropTypes.object
          ])

  render: ->
    return null unless @props.hint?
    <span className="help-block">
      {@props.hint}
    </span>
