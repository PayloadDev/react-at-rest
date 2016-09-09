RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'

_ =
  extend:    require 'lodash/object/extend'
  omit:      require 'lodash/object/omit'
  startCase: require 'lodash/string/startCase'

React      = require 'react'
classNames = require 'classnames'


module.exports = class CheckboxInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    hideLabel:      React.PropTypes.bool
    inputClassName: React.PropTypes.string
    onBlur:         React.PropTypes.func

  @defaultProps =
    hideLabel: false

  render: ->
    className  = classNames 'checkbox', @props.className

    <div className={className}>
      <FieldWrapper errors={@props.errors} formGroup={false}>
        <label className={@props.labelClassName}>
          <div className={@props.inputWrapperClassName}>
            <input
              {..._.omit(@props, 'errors', 'hideLabel', 'hint', 'inputClassName', 'inputType', 'inputWrapperClassName', 'labelClassName')}
              className={@props.inputClassName}
              checked={@props.value ? ''}
              type='checkbox'
              onChange={@handleChange} />
            {unless @props.hideLabel then @props.label ? _.startCase @props.name}
          </div>
        </label>
        <FieldHint hint={@props.hint} className={@props.hintClassName} />
      </FieldWrapper>
    </div>
