EventableComponent = require './eventable_component'
RSVP               = require 'rsvp'
Utils              = require '../utils'

_ =
  isArray:    require 'lodash/lang/isArray'
  isEqual:    require 'lodash/lang/isEqual'
  isFunction: require 'lodash/lang/isFunction'
  keys:       require 'lodash/object/keys'
  last:       require 'lodash/array/last'
  merge:      require 'lodash/object/merge'
  without:    require 'lodash/array/without'


# DeliveryService brings Resources from the Store
module.exports = class DeliveryService extends EventableComponent

  @displayName = 'DeliveryService'

  metaKey:       'meta'
  defaultQuery:  null
  routeParamKey: null


  constructor: (props) ->
    @boundResources = []
    @state =
      loaded: false


  componentDidMount: ->
    @bindResources @props
    @getResources() if @boundResources.length


  componentWillUnmount: ->
    @stopListening()
    @stopPolling()
    @componentHasUnmounted = true


  componentWillReceiveProps: (nextProps) ->
    # if React.Router is being used, do some additional change checks agains the URL
    if nextProps.params? or nextProps.location?
      idSegment = @routeParamKey ? _.last (k for k,v of nextProps.params when k[-2..] is 'Id')

      if idSegment?
        idChanged = nextProps.params?[idSegment] isnt @props.params?[idSegment]
      else
        idChanged = false

      # the idSegment is the first dynamic param present in the @props.params object from the router.
      # it is the segment that represents the parent object which is what needs to be reloaded when the url changes.
      # if this segment hasn't changed, no need to reload all the bound resources.
      return if not idChanged and _.isEqual(nextProps.location?.query, @props.location?.query)

      # show the loading UI unless we're just updating the query
      @setState loaded: false if idChanged

    @stopPolling()
    @stopListeningToBoundResources()
    # remove all bound resources
    @boundResources = []
    @bindResources nextProps
    @getResources() if @boundResources.length


  bindResources: (props) ->
    # override in child class


  resourcesWillLoad: ->
    # override in child class


  resourcesDidLoad: ->
    # override in child class


  bindResource: (store, eventName, callback=@setStateFromStore, options={}) ->
    defaults = if _.isFunction @defaultQuery then @defaultQuery(store) else @defaultQuery
    options.query = _.merge {}, defaults, options.query if defaults?

    @boundResources.push
      store:     store
      eventName: eventName
      options:   options
      callback:  callback


  # Notes for: subscribeAll, subscribeResource, retrieveAll, retrieveResource
  #
  # The 'subscribe*' methods request the resource then poll for changes
  # The 'retrieve*' methods request the resource a single time
  #
  # - subscribed resources are fetched when the component mounts and when the component receives props
  # - resources are denormalized by the store and attached to the component's state
  # - the component starts listening to the subscribed event on the store
  # - the store starts polling subscribed resources
  # - events are cleared and polling is stopped when the component unmounts
  #
  # @param    store               [Object]   The store which is managing the resources
  # @param    options             [Object]   Options to pass to the store. Options: id, parentResource, query.
  #           options.callback    [Function] Method to bind the event to (Optional)
  #
  # alternative (1.0 compatible) signature: (store, callback, options)
  # as of 2.0.0 DeliveryService accepts both signatures but (store, options) is preferred
  #
  subscribeAll: (store, rest...) ->
    options = @mungeArgs rest
    @bindResource store, 'reset', options.callback, options


  subscribeResource: (store, rest...) ->
    options = @mungeArgs rest
    @bindResource store, 'fetch', options.callback, options


  retrieveAll: (store, rest...) ->
    options = @mungeArgs rest
    @bindResource store, 'resetonce', options.callback, options


  retrieveResource: (store, rest...) ->
    options = @mungeArgs rest
    @bindResource store, 'fetchonce', options.callback, options


  mungeArgs: (args) ->
    if _.isFunction args[0]
      options = callback: args[0]
      options = _.merge options, args[1] ? {}
    else
      options = args[0]
    options


  # tell the store to retrieve all the bound resources
  getResources: ->
    requests = for sub in @boundResources
      if sub.eventName in ['fetch', 'fetchonce']
        sub.store.getResource sub.options.id, sub.options
      else
        sub.store.getAll sub.options

    # fire lifecycle method
    @resourcesWillLoad()

    RSVP.all(requests)
      .then(@setStateFromStore)
      .then(@startPollingBoundResources)
      .then(@startListeningToBoundResources)
      .then(@resourcesDidLoad)


  # consumes all the data returned from the API and merges it onto the component's state
  setStateFromStore: (data) =>
    return if @componentHasUnmounted

    newState =
      loaded: true

    # ensure data is an array so we can iterate over it
    data = [data] unless _.isArray data

    for resources in data
      resourceKey = _.without(_.keys(resources), @metaKey)?[0]

      newState[resourceKey] = resources[resourceKey]
      newState["#{resourceKey}#{Utils.capitalize @metaKey}"] = resources[@metaKey]

    @setState newState


  startPollingBoundResources: =>
    for sub in @boundResources
      do (sub) =>
        if sub.eventName in ['fetch', 'reset']
          @listenTo sub.store, sub.eventName, sub.callback
          sub.store.startPolling sub.options


  startListeningToBoundResources: =>
    for sub in @boundResources
      do (sub) =>
        # ensure local creates/updates are synced to the state
        if sub.eventName in ['reset', 'resetonce']
          @listenTo sub.store, 'create', (resource, resources) =>
            (sub.callback) resources
          @listenTo sub.store, 'destroy', (resources) =>
            (sub.callback) resources
          @listenTo sub.store, 'update', (resource, resources) =>
            (sub.callback) resources

        # when fetching a single resource, trigger an update when that specific resource is updated
        if sub.eventName in ['fetch', 'fetchonce']
          @listenTo sub.store, 'update', (resource, resources) =>
            if parseInt(resource[sub.store.resourceKey].id) is parseInt(sub.options?.id)
              (sub.callback) resource


  stopPolling: ->
    sub.store.stopPolling() for sub in @boundResources


  stopListeningToBoundResources: =>
    for sub in @boundResources
      if sub.eventName in ['fetch', 'reset']
        @stopListening sub.store, sub.eventName, sub.callback
      # stop local events
      if sub.eventName in ['reset', 'resetonce']
        @stopListening sub.store, 'create'
        @stopListening sub.store, 'destroy'

      @stopListening sub.store, 'update'


  render: ->
    <div/>

