React = require 'react'
_ =
  isEqual: require 'lodash/lang/isequal'


module.exports = class RestFormElement extends React.Component

  @propTypes =
    disabled:              React.PropTypes.bool
    hint:                  React.PropTypes.string
    inputWrapperClassName: React.PropTypes.string
    label:                 React.PropTypes.string
    labelClassName:        React.PropTypes.string
    name:                  React.PropTypes.string.isRequired
    onChange:              React.PropTypes.func,
    required:              React.PropTypes.bool
    errors:                React.PropTypes.array
    value:                 React.PropTypes.any


  constructor: (props) ->
    @state =
      value: props.value or props.defaultValue


  componentWillMount: ->
    if @props.defaultValue and not @props.value
      @props.onChange @props.name, @props.defaultValue


  componentWillReceiveProps: (nextProps) ->
    # update the input with a value passed down from the form
    @setState value: nextProps.value


  shouldComponentUpdate: (nextProps, nextState) ->
    # always render if entering or leaving an error state
    return true if (nextProps.errors or (@props.errors and @props.errors.length) or nextState.errors)
    # self-imposed state changes should update
    return true unless _.isEqual(nextState, @state)
    # prevent re-renders if the incoming value hasn't changed
    return false if _.isEqual(nextState.value, @props.value)
    # no need to re-render if we're just setting the default value
    return false if _.isEqual @props.defaultValue, nextState.value

    true


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
      else el.value

    @setState value: value
    @props.onChange @props.name, value
