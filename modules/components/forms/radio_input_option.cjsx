classNames     = require 'classnames'
shallowCompare = require 'react-addons-shallow-compare'

module.exports = class RadioInputOption extends React.Component

  @displayName = 'RadioInputOption'


  @propTypes =
    checked:  React.PropTypes.bool
    disabled: React.PropTypes.bool
    name:     React.PropTypes.string.isRequired
    onChange: React.PropTypes.func.isRequired
    value:    React.PropTypes.any.isRequired


  @defaultProps =
    checked:  false
    disabled: false


  shouldComponentUpdate: (nextProps, nextState) ->
    shallowCompare @, nextProps, nextState


  render: ->
    <div className='radio'>
      <label>
        <input
          name={@props.name}
          checked={@props.checked}
          value={@props.value}
          disabled={@props.disabled}
          type='radio'
          onChange={@props.onChange} />
        {@props.name}
        <br/>
      </label>
    </div>
