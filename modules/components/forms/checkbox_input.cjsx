RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'

_          = require 'lodash'
React      = require 'react'
classNames = require 'classnames'


module.exports = class CheckboxInput extends RestFormElement

  @propTypes = _.extend {}, RestFormElement.propTypes,
    onBlur: React.PropTypes.func


  render: ->
    className = classNames 'checkbox', @props.className

    <div className={className}>
      <FieldWrapper errors={@props.errors}>
        <label className={@props.labelClassName}>
          <div className={@props.inputWrapperClassName}>
            <input
              name={@props.name}
              checked={@state.value}
              type='checkbox'
              onChange={@handleChange}
              onBlur={@props.onBlur} />
            {@props.label ? _.startCase @props.name}
          </div>
        </label>
      </FieldWrapper>
    </div>
