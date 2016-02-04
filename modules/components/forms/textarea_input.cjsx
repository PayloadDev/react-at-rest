RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'
Label           = require './label'

React      = require 'react'
classNames = require 'classnames'

_ =
  extend:  require 'lodash/object/extend'
  isEqual: require 'lodash/lang/isEqual'


module.exports = class TextAreaInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    className:    React.PropTypes.string
    hideLabel:    React.PropTypes.bool
    onChange:     React.PropTypes.func
    value:        React.PropTypes.string


  shouldComponentUpdate: (nextProps, nextState) ->
    unless _.isEqual nextProps.style, @props.style
      return true
    super nextProps, nextState


  render: ->
    label = null
    unless @props.hideLabel
      label = <Label
        label={@props.label}
        name={@props.name}
        modelType={@props.modelType}
        required={@props.required}
        className={classNames "control-label", @props.labelClassName} />

    classes = classNames 'form-control', @props.className

    <FieldWrapper errors={@props.errors}>
      {label}
      <div className={@props.inputWrapperClassName}>
        <textarea
          {...@props}
          value={@state.value}
          className={classes}
          onChange={@handleChange} />
      </div>
      <FieldHint hint={@props.hint} />
      <FieldErrors errors={@props.errors}/>
    </FieldWrapper>
