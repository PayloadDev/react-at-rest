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
    hideLabel:   React.PropTypes.bool
    inputType:   React.PropTypes.string
    onChange:    React.PropTypes.func
    style:       React.PropTypes.object

  @defaultProps =
    inputType: 'text'


  render: ->
    unless @props.hideLabel
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
            ref='element'
            {...@props}
            value={@state.value}
            className="form-control"
            onChange={@handleChange} />
          <FieldHint hint={@props.hint} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
