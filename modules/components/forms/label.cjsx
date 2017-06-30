PropTypes = require 'prop-types'
React     = require 'react'

_ =
  startCase:    require 'lodash/string/startCase'

module.exports = class Label extends React.Component

  @displayName = 'Label'

  @propTypes =
    className: PropTypes.string
    label:     PropTypes.any
    modelType: PropTypes.string
    name:      PropTypes.string
    required:  PropTypes.bool
    style:     PropTypes.object


  render: ->
    labelText = @props.label ? _.startCase @props.name

    required = <span className='required'><i className="fa fa-asterisk"/></span> if @props.required

    <label
      title={"Required field" if @props.required}
      className={@props.className}
      style={@props.style}>
      {labelText}{required}
    </label>
