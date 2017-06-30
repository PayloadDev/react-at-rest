PropTypes      = require 'prop-types'
React          = require 'react'
shallowCompare = require 'react-addons-shallow-compare'

module.exports = class RestFormElement extends React.Component

  @propTypes =
    disabled:              PropTypes.bool
    hint:                  PropTypes.string
    hintClassName:         PropTypes.string
    inputWrapperClassName: PropTypes.string
    label:                 PropTypes.string
    labelClassName:        PropTypes.string
    name:                  PropTypes.string.isRequired
    onChange:              PropTypes.func
    required:              PropTypes.bool
    errors:                PropTypes.array
    value:                 PropTypes.any

  @defaultProps =
    value: ''

  constructor: (props) ->
    super props


  componentWillMount: ->
    if @props.defaultValue and not @props.value
      @props.onChange @props.name, @props.defaultValue


  shouldComponentUpdate: (nextProps, nextState) ->
    shallowCompare @, nextProps, nextState


  #
  # Consumes the UI element's change event and determines the correct value to pass to the
  # form's model
  #
  # @param e [Event] the change event generated in the UI
  #
  handleChange: (e) =>
    el = e.target
    type = el.type

    value = switch type
      when 'select-multiple' then el.selectedOptions
      when 'checkbox' then el.checked
      else el.value ? ''

    @props.onChange @props.name, value
