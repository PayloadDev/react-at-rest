RestFormElement = require '../rest_form_element'
Label           = require './label'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'

React      = require 'react'
classNames = require 'classnames'

module.exports = class SelectInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    autoFocus: React.PropTypes.bool
    divClass:  React.PropTypes.string
    hideLabel: React.PropTypes.bool
    multiple:  React.PropTypes.bool
    onChange:  React.PropTypes.func
    options:   React.PropTypes.array
    prompt:    React.PropTypes.bool

  @defaultProps =
    prompt: true


  componentDidMount: ->
    # push the first option onto the model if no value was specified and prompt is disabled
    @props.onChange @props.name, @props.options[0].id unless @props.prompt or @props.value?


  render: ->
    unless @props.hideLabel
      label = <Label
        label={@props.label}
        name={@props.name}
        modelType={@props.modelType}
        required={@props.required}
        className={classNames 'control-label', @props.labelClassName} />

    selectOptions = for opt in @props.options
      id = opt.id ? opt
      name = opt.name ? opt
      <option key={id} value={id}>{name}</option>

    if @props.prompt
      selectOptions.unshift <option key="-1">Choose one...</option>

    <div className={@props.className} style={@props.style}>
      <FieldWrapper errors={@props.errors}>
        {label}
        <div className={@props.inputWrapperClassName}>
          <select
            autoFocus={@props.autoFocus}
            multiple={@props.multiple}
            onChange={@handleChange}
            className='form-control'
            value={@props.value}
            defaultValue={@props.defaultValue} >
            {selectOptions}
          </select>
          <FieldHint hint={@props.hint} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
