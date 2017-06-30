classNames = require 'classnames'
PropTypes  = require 'prop-types'
React      = require 'react'

module.exports = class FieldHint extends React.Component

  @displayName = 'FieldHint'

  @propTypes =
    className: PropTypes.string
    hint:      PropTypes.oneOfType([
                PropTypes.string
                PropTypes.object
              ])

  render: ->
    return null unless @props.hint?

    <span className={classNames 'help-block', @props.className}>
      {@props.hint}
    </span>
