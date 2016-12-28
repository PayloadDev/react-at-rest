React = require 'react'
_ =
  isEqual:   require 'lodash/lang/isEqual'
  isEmpty:   require 'lodash/lang/isEmpty'
  cloneDeep: require 'lodash/lang/cloneDeep'
  first:     require 'lodash/array/first'
  last:      require 'lodash/array/last'
  pick:      require 'lodash/object/pick'
  compact:   require 'lodash/array/compact'
  reject:    require 'lodash/collection/reject'


module.exports = class SubFormArray extends React.Component

  @propTypes =
    addResourceButton:   React.PropTypes.node
    destroyWorkaround:   React.PropTypes.bool
    errors:              React.PropTypes.array
    name:                React.PropTypes.string
    newItemTemplate:     React.PropTypes.object
    onChange:            React.PropTypes.func
    permittedProperties: React.PropTypes.array
    value:               React.PropTypes.array
    wrapperClassName:    React.PropTypes.string

  @defaultProps =
    componentTagName:    'div'
    destroyWorkaround:   false
    newItemTemplate:     {}
    permittedProperties: []
  # when singular=true, don't render +/- UI elements
    singular:            false
    value:               [{}]


  componentDidMount: ->
    # since the subform is a child of another model, we'll need every item in the array for the later ajax request
    # use @props.permittedProperties to filter out unneeded properties
    value =
      if _.isEmpty @props.permittedProperties
        _.cloneDeep @props.value
      else
        (_.pick v, @props.permittedProperties for v in @props.value when v isnt null)

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
    e.preventDefault()
    @props.onChange "#{@props.name}[#{@props.value.length}]", _.cloneDeep(@props.newItemTemplate)


  # capture the index at render time and return an event handler
  removeItem: (index) ->
    (e) =>
      value = if @props.destroyWorkaround and @props.value[index]?.id
        id:       @props.value[index]?.id
        _destroy: '1'
      else
        null

      @props.onChange("#{@props.name}[#{index}]", value)


  render: ->
    addItemButton = if @props.addResourceButton?
      React.cloneElement @props.addResourceButton,
        key:     'addItemButton'
        onClick: @addItem

    # Due to the fact that we have a destroyWorkaround we can't trust that the index
    # represents the true representation of the first element. So grab the indexes of
    # the actual persisted records so we can pass the first and last to the subform.
    persistedRecords = (index for prop,index in @props.value when prop?._destroy isnt '1' and prop?)
    firstRecordIndex = _.first persistedRecords
    lastRecordIndex  = _.last persistedRecords

    # since the real "index" includes destroyed items, pass a displayIndex showing where this item is
    # in the list of subforms being displayed. Not zero-indexed (since it's for display purposes)
    displayIndex = 0

    # attach the props to all the children
    childComponents = for model, index in @props.value
      # handle destroyed items and null items
      if not model? or (@props.destroyWorkaround and model?._destroy is '1') then continue

      displayIndex++

      React.Children.map @props.children, (child) =>
        name = "#{@props.name}[#{index}]"

        React.cloneElement child,
          key:          name
          errors:       @props.errors?[index]
          firstRecord:  firstRecordIndex is index
          lastRecord:   lastRecordIndex is index
          index:        index
          displayIndex: displayIndex
          model:        _.cloneDeep model
          name:         name
          onChange:     @propagateChanges
          onRemove:     @removeItem index

    React.createElement @props.componentTagName,
      className: @props.wrapperClassName,
        [childComponents, addItemButton]
