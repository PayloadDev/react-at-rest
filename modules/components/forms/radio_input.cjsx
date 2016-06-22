FieldWrapper     = require './field_wrapper'
FieldErrors      = require './field_errors'
FieldHint        = require './field_hint'
Label            = require './label'
React            = require 'react'
RestFormElement  = require '../rest_form_element'

classNames = require 'classnames'
_ =
  extend: require 'lodash/object/extend'


module.exports = class RadioInput extends RestFormElement

  @displayName = 'RadioInput'


  @propTypes = _.extend {}, RestFormElement.propTypes,
    options: React.PropTypes.arrayOf React.PropTypes.shape(
      name:     React.PropTypes.string.isRequired
      value:    React.PropTypes.any.isRequired
      disabled: React.PropTypes.bool
    )

  @defaultProps =
    options: []


  renderOption: (option) ->
    checked = @props.value?.toString() is option.value.toString()

    <div className='radio' key={option.name}>
      <label>
        <input
          name={option.name}
          checked={checked}
          value={option.value}
          disabled={option.disabled}
          type='radio'
          onChange={@handleChange}
          className={@props.inputClassName} />
        {option.name}
        <br/>
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
          {@renderOption option for option in @props.options}
          <FieldHint hint={@props.hint} className={@props.hintClassName} />
          <FieldErrors errors={@props.errors} />
        </div>
      </FieldWrapper>
    </div>
