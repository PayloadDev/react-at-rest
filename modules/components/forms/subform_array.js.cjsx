React = require 'react'
_     = require 'lodash'

module.exports = class SubFormArray extends React.Component

  @propTypes =
    destroyWorkaround:   React.PropTypes.bool
    errors:              React.PropTypes.object
    name:                React.PropTypes.string
    onChange:            React.PropTypes.func
    permittedProperties: React.PropTypes.array
    value:               React.PropTypes.array
    wrapperClassName:    React.PropTypes.string

  @defaultProps =
  # when singular=true, don't render +/- UI elements
    singular:            false
    permittedProperties: []
    wrapperClassName:    'well well-sm'
    destroyWorkaround:   false


  componentDidMount: ->
    # since the subform is a child of another model, we'll need every item in the array for the later ajax request
    # use @props.permittedProperties to filter out unneeded properties
    value =
      if _.isEmpty @props.permittedProperties
        _.cloneDeep @props.value
      else
        (_.pick v, @props.permittedProperties for v in @props.value)

    @props.onChange @props.name, value


  shouldComponentUpdate: (nextProps, nextState) ->
    # update if there are errors
    if @hasNewErrors nextProps, @props
      return true
    # update if the values have changed
    not _.isEqual nextProps.value, @props.value


  # Detect if new errors have been reported
  hasNewErrors: (nextProps, props) ->
    not _.isEmpty(nextProps.errors) or not _.isEqual(props.errors, nextProps.errors)


  # push this form's model up to parent form
  propagateChanges: (nextPatch, nextModel, sourceComponent) =>
    @props.onChange sourceComponent.props.name, nextModel


  addItem: (e) =>
    @props.onChange "#{@props.name}[#{@props.value.length}]", {}


  # capture the index at render time and return an event handler
  removeItem: (index) ->
    (e) =>
      value = if @props.destroyWorkaround
        id:       @props.value[index].id
        _destroy: '1'
      else
        null

      @props.onChange "#{@props.name}[#{index}]", value


  render: ->
    # ignore "null" values
    models = _.compact _.reject(@props.value, _destroy: '1')

    if models is [] then models = [{}]

    # attach the props to all the children
    childComponents = for model, index in models
      React.Children.map @props.children, (child) =>
        childComponent = React.cloneElement child,
          errors:   @props.errors
          model:    _.cloneDeep model
          name:     "#{@props.name}[#{index}]"
          onChange: @propagateChanges
        delBtn = <a className="btn btn-xs btn-danger pull-right" onClick={@removeItem index}>
          <i className='fa-trash fa'/> {t 'buttons.delete'}
        </a> unless @props.singular

        <div className={@props.wrapperClassName}>
          {delBtn}
          {childComponent}
        </div>

    addBtn = <a className="btn btn-xs btn-default" onClick={@addItem}>
      <i className='fa-plus fa'/>
    </a> unless @props.singular

    <div>
      {childComponents}
      {addBtn}
    </div>
