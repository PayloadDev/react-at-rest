React = require 'react'
_ =
  isEqual: require 'lodash/lang/isEqual'


module.exports = class SubForm extends React.Component

  @displayName: 'SubForm'

  @propTypes:
    name:     React.PropTypes.string
    onChange: React.PropTypes.func
    value:    React.PropTypes.object


  shouldComponentUpdate: (nextProps, nextState) ->
    not _.isEqual nextProps, @props


  propagateChanges: (nextPatch, nextModel) =>
    @props.onChange @props.name, nextModel


  renderChildren: ->
    React.Children.map @props.children, (child) =>
      React.cloneElement child,
        onChange: @propagateChanges
        model:    @props.value ? {}


  render: ->
    <div>
      {@renderChildren()}
    </div>
