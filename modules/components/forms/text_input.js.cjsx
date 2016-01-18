RestFormElement = require '../rest_form_element'
Label           = require './label'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'

React      = require 'react'
_          = require 'lodash'
classNames = require 'classnames'

module.exports = class TextInput extends RestFormElement

  @propTypes = _.extend RestFormElement.propTypes,
    autoFocus:   React.PropTypes.bool
    hideLabel:   React.PropTypes.bool
    inputType:   React.PropTypes.string
    onBlur:      React.PropTypes.func
    onChange:    React.PropTypes.func
    onClick:     React.PropTypes.func
    onFocus:     React.PropTypes.func
    onKeyPress:  React.PropTypes.func
    placeholder: React.PropTypes.string
    style:       React.PropTypes.object
    tabIndex:    React.PropTypes.number

  @defaultProps =
    autoFocus: false
    inputType: 'text'


  render: ->
    if not @props.hideLabel
      labelClassName = classNames 'control-label', @props.labelClassName
      label = <Label
        label={@props.label}
        name={@props.name}
        required={@props.required}
        className={labelClassName}/>

    <div className={@props.className} style={@props.style}>
      <FieldWrapper errors={@props.errors}>
        {label}
        <div className={@props.inputWrapperClassName}>
          <input
            name={@props.name}
            value={@state.value}
            type={@props.inputType}
            className="form-control"
            placeholder={@props.placeholder}
            autoFocus={@props.autoFocus}
            disabled={@props.disabled}
            tabIndex={@props.tabIndex}
            onChange={@handleChange}
            onClick={@props.onClick}
            onFocus={@props.onFocus}
            onBlur={@props.onBlur}
            onKeyPress={@props.onKeyPress} />
          <FieldHint hint={@props.hint} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
