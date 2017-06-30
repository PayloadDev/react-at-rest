RestFormElement = require '../rest_form_element'
Label           = require './label'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'
FieldErrors     = require './field_errors'

classNames = require 'classnames'
PropTypes  = require 'prop-types'
React      = require 'react'

_ =
  extend: require 'lodash/object/extend'
  omit:   require 'lodash/object/omit'


module.exports = class SelectInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    hideLabel:      PropTypes.bool
    inputClassName: PropTypes.string
    multiple:       PropTypes.bool
    onChange:       PropTypes.func
    options:        PropTypes.array
    prompt:         PropTypes.bool
    promptText:     PropTypes.string

  @defaultProps =
    prompt:      true
    promptText: 'Choose one...'


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
      selectOptions.unshift <option key="-1">{@props.promptText}</option>

    inputClassName = classNames 'form-control', @props.inputClassName

    <div className={@props.className} style={@props.style}>
      <FieldWrapper errors={@props.errors}>
        {label}
        <div className={@props.inputWrapperClassName}>
          <select
            {..._.omit(@props, 'errors', 'hideLabel', 'inputClassName', 'inputWrapperClassName', 'labelClassName', 'options', 'prompt', 'promptText')}
            className={inputClassName}
            onChange={@handleChange}>
            {selectOptions}
          </select>
          <FieldHint hint={@props.hint} className={@props.hintClassName} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
