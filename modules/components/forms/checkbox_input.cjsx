RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'
FieldHint       = require './field_hint'

_ =
  extend:    require 'lodash/object/extend'
  omit:      require 'lodash/object/omit'
  startCase: require 'lodash/string/startCase'

classNames = require 'classnames'
PropTypes  = require 'prop-types'
React      = require 'react'


module.exports = class CheckboxInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    hideLabel:      PropTypes.bool
    inputClassName: PropTypes.string
    onBlur:         PropTypes.func

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
