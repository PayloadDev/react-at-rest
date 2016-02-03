React = require 'react'
_ =
  startCase:    require 'lodash/string/startCase'

module.exports = class Label extends React.Component

  @displayName = 'Label'

  @propTypes =
    className: React.PropTypes.string
    label:     React.PropTypes.any
    modelType: React.PropTypes.string
    name:      React.PropTypes.string
    required:  React.PropTypes.bool
    style:     React.PropTypes.object


  render: ->
    labelText = @props.label ? _.startCase @props.name

    required = <span className='required'><i className="fa fa-asterisk"/></span> if @props.required

    <label
      title={"Required field" if @props.required}
      className={@props.className}
      style={@props.style}>
      {labelText}{required}
    </label>
