RestFormElement = require '../rest_form_element'
Label           = require './label'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'

React      = require 'react'
classNames = require 'classnames'

_ =
  extend: require 'lodash/object/extend'
  omit:   require 'lodash/object/omit'


module.exports = class TextInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    hideLabel:      React.PropTypes.bool
    inputClassName: React.PropTypes.string
    inputType:      React.PropTypes.string
    onChange:       React.PropTypes.func
    style:          React.PropTypes.object

  @defaultProps = _.extend {}, RestFormElement.defaultProps,
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
            {..._.omit(@props, 'errors', 'hideLabel', 'hint', 'inputClassName', 'inputType', 'inputWrapperClassName', 'labelClassName')}
            type={@props.inputType}
            value={@props.value ? ''}
            className={classNames 'form-control', @props.inputClassName}
            onChange={@handleChange} />
          <FieldHint hint={@props.hint} className={@props.hintClassName} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
