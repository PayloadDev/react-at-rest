React = require 'react'

# Place within a form where a generic error message can be returned
module.exports = class ErrorSummary extends React.Component

  @propTypes =
    message: React.PropTypes.string


  render: ->
    return null unless @props.message?

    <div className="alert alert-danger">
      {@props.message}
    </div>
