RestFormElement = require '../rest_form_element'
FieldWrapper    = require './field_wrapper'

_ =
  extend:    require 'lodash/object/extend'
  startCase: require 'lodash/string/startcase'

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
              {...@props}
              checked={@state.value}
              type='checkbox'
              onChange={@handleChange} />
            {@props.label ? _.startCase @props.name}
          </div>
        </label>
      </FieldWrapper>
    </div>
