RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'
FieldErrors     = require './field_errors'
FieldHint       = require './field_hint'
Label           = require './label'

classNames = require 'classnames'


module.exports = class RadioInput extends RestFormElement

  @displayName = 'RadioInput'

  renderRadioOptions: ->
    for option in @props.options
      <div className='radio' key={option.value}>
        <label>
          <input
            name={@props.name}
            checked={@state.value?.toString() is option.value.toString()}
            value={option.value}
            type='radio'
            onChange={@handleChange} />
          {option.name}<br/>
        </label>
      </div>


  render: ->
    labelClassName = classNames 'control-label', @props.labelClassName
    label = <Label
      label={@props.label}
      name={@props.name}
      required={@props.required}
      className={labelClassName}/> if @props.label

    className = classNames @props.className, 'has-radio'

    <div className={className}>
      <FieldWrapper errors={@props.errors}>
        {label}
        <div className={@props.inputWrapperClassName}>
          {@renderRadioOptions()}
          <FieldHint hint={@props.hint} className={@props.hintClassName} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
