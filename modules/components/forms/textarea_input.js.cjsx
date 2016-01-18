RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'
Label           = require './label'

React      = require 'react'
_          = require 'lodash'
classNames = require 'classnames'

module.exports = class TextAreaInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    autoFocus:    React.PropTypes.bool
    className:    React.PropTypes.string
    hideLabel:    React.PropTypes.bool
    onChange:     React.PropTypes.func
    placeholder:  React.PropTypes.string
    rows:         React.PropTypes.oneOfType([
                    React.PropTypes.string
                    React.PropTypes.number
                  ])
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
          name={@props.name}
          defaultValue={@props.defaultValue}
          value={@state.value}
          className={classes}
          placeholder={@props.placeholder}
          rows={@props.rows}
          autoFocus={@props.autoFocus}
          onChange={@handleChange}
          onClick={@props.onClick}
          onFocus={@props.onFocus}
          onBlur={@props.onBlur}
          style={@props.style} />
      </div>
      <FieldHint hint={@props.hint} />
      <FieldErrors errors={@props.errors}/>
    </FieldWrapper>
