React = require 'react'

module.exports = class FieldHint extends React.Component

  @displayName = 'FieldHint'

  @propTypes =
    hint: React.PropTypes.string

  render: ->
    return null unless @props.hint?
    <span className="help-block">
      {@props.hint}
    </span>
