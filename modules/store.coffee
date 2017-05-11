AppEvents = require './app_events'
Events    = require '../vendor/events'
Resource  = require './resource'
Utils     = require './utils'

RSVP              = require 'rsvp'
superagent        = require 'superagent'
superagentNoCache = require 'superagent-no-cache'

_ =
  bind:       require 'lodash/function/bind'
  defaults:   require 'lodash/object/defaults'
  difference: require 'lodash/array/difference'
  extend:     require 'lodash/object/extend'
  find:       require 'lodash/collection/find'
  pluck:      require 'lodash/collection/pluck'
  remove:     require 'lodash/array/remove'
  snakeCase:  require 'lodash/string/snakeCase'


# Base Store class that handles all API CRUD
#
# @example
#   ProposalReuestStore = new Store('proposalRequests')
#   ProposalReuestStore.getResource(123)
#
# @example
#   ActivityStore = new Store('activities', 'activity')
#   ActivityStore.getResource(123)
#
# @param resourcesKey [String] String used to find the collection of resources within a response.
# @param resourceKey  [String] Optional. String used to find the singular resource within a response.
#
# @return [Object] Store class
class Store

  @API_PATH_PREFIX:      ''
  @API_ENVELOPE:         true
  @DEFAULT_CONTENT_TYPE: 'application/json'
  @SUPERAGENT_PLUGINS:   []

  ResourceClass: Resource

  constructor: (@resourcesKey, @resourceKey) ->
    @resources = {}
    @resourceKey ?= Utils.singularize @resourcesKey
    @resources[@resourcesKey] = []


  # Appends/updates an item in the Store cache
  #
  # @param data     [Object]
  # @param policies [Object]
  #
  # @return [Object] Stored object
  storeResource: (data, policies) ->
    newResource = new @ResourceClass data, policies

    # replace resource if it already exists
    for resource, index in @resources[@resourcesKey]
      if resource.id is data.id
        @resources[@resourcesKey][index] = newResource
        replaced = true

    @resources[@resourcesKey].push newResource unless replaced
    newResource


  # Remove a resource from the store
  unstoreResource: (id) ->
    _.remove @resources[@resourcesKey], id: id


  # Remove all resources from the store
  clearResources: ->
    @resources[@resourcesKey] = []


  # Get a specific resource
  getStoredResource: (id) ->
    _.find @getStoredResources(), id: parseInt(id,10)


  # Get resources array
  getStoredResources: ->
    @resources[@resourcesKey]


  # stores the metadata associated with the most recent response
  setMeta: (data) ->
    @resources.meta = data.meta


  # Load all resources from API
  #
  # @param options  [Object]                      Optional properties
  # @option options [String]  parentResourcesKey  Name of parent resource
  # @option options [Number]  parentResourceId    Required if parentResourcesKey specified. Id of parent resource.
  # @option options [Object]  query               Querystring object to pass onto the API for sort/filter/etc
  # @option options [Object]  namespace           Namespace to use when returning data. Defaults to the resourcesKey.
  #
  # @return [Object] Promise
  #
  getAll: (options={}) =>
    url = @getPath 'index', null, options

    @index(url)
      .then (data) =>
        data = @parseAll data
        root = if Store.API_ENVELOPE then data[@resourcesKey] else data

        unless root?
          throw new Error "Store.getAll: Unable to parse API response."

        # clear the existing resources
        @clearResources()
        # store the resources
        for resource in root
          @storeResource resource, @getPolicies(data, resource.id)

        @setMeta data

        key       = options.namespace ? @resourcesKey
        resources =
          meta:     @resources.meta
          "#{key}": @getStoredResources()

        @trigger 'reset', resources

        resources


  # Load single resource from API
  #
  # @param id       [Number]               Resource ID
  # @param options  [Object]               Optional properties
  # @option options [Boolean] cache        When true, return the resource from the cache if possible
  # @option options [Boolean] namespace    Namespace to use when returning data. Defaults to the resourceKey
  #
  # @return [Object] Promise
  #
  getResource: (id, options={}) ->
    key = options.namespace ? @resourceKey

    if options.cache
      resource = @getStoredResource id
      return RSVP.Promise.resolve("#{key}": resource) if resource?

    url = @getPath 'show', id, options
    @get(url)
      .then (data) =>
        data = @parseResource data
        root = if Store.API_ENVELOPE then data[@resourceKey] else data

        unless root?
          throw new Error "Store.getResource: Unable to parse API response."

        resource = @storeResource root, @getPolicies(data, root.id) if root?
        @trigger 'fetch', "#{key}": resource

        meta:     data.meta
        "#{key}": resource


  # Create resource
  #
  # @param model            [Object]                      Model resource attribute/value pairs
  # @param options          [Object]                      Optional. Parent resource properties and/or query string.
  # @option options         [String]  parentResourcesKey  Name of parent resource
  # @option options         [Number]  parentResourceId    Required if parentResourcesKey specified. Id of parent resource.
  # @option options         [Object]  query               Query string options
  #
  # @return [Object] Promise
  #
  createResource: (model, options={}) ->
    url  = @getPath 'create', null, options
    @post(url, model)
      .then (data) =>
        data     = @parseResource data
        root     = if Store.API_ENVELOPE then data[@resourceKey] else data
        resource = @storeResource root, @getPolicies(data, root.id) if root?

        @trigger 'create', "#{@resourceKey}": resource, @resources

        "#{@resourceKey}": resource


  # Update resource
  #
  # @param id     [Number]  Resource ID
  # @param patch  [Object]  Modified resource attribute/value pairs
  #
  # @return [Object] Promise
  #
  updateResource: (id, patch, options) ->
    url  = @getPath 'update', id, options
    @update(url, patch)
      .then (data) =>
        data     = @parseResource data
        root     = if Store.API_ENVELOPE then data[@resourceKey] else data
        resource = @storeResource root, @getPolicies(data, root.id) if root?
        @trigger 'update', "#{@resourceKey}": resource, @resources

        "#{@resourceKey}": resource


  # Destroy resource
  #
  # @param id [Number] Resource ID
  #
  # @return [Object] promise
  #
  destroyResource: (id) ->
    url  = @getPath 'destroy', id
    @delete(url)
      .then (data) =>
        @unstoreResource id
        @trigger 'destroy', @resources, id


  # Given the raw AJAX data, return the associated policies
  # This method is inteded to be overridden by Stores that interface with APIs that provide policies
  getPolicies: (data, id) ->
    null


  # Parse all the data from the API response
  # This method is intended to be overridden by any Store which needs to parse its data
  #
  # @param data  [Object]   The API response object (JSON)
  # @param query [Object]   Querystring filter
  #
  # @return [Object]        The parsed data (JSON)
  parseAll: (data) ->
    data


  # Parse a single resource
  # This method is intended to be overridden by any Store which needs to parse its data
  #
  # @param data [Object]    The API response object (JSON)
  #
  # @return [Object]        The parsed data (JSON)
  parseResource: (data) ->
    data


  # Start polling the resources API
  #
  # @param options          [Object]                      Optional. Parent resource properties.
  # @option options         [Number]  id                  Id of the resource to poll.
  # @option options         [String]  parentResourcesKey  Name of parent resource
  # @option options         [Number]  parentResourceId    Required if parentResourcesKey specified. Id of parent resource.
  # @option options         [Object]  query               The query string parameters
  # @option options         [Number]  delay               Frequency to poll. Defaults to 15s.
  #
  startPolling: (options={}) ->
    _.defaults options, delay: 15000
    unless @timer
      @timer =
        # @TODO: catch errors and stop polling?
        if options.id
          setInterval _.bind(@getResource, @, options.id, options), options.delay
        else
          setInterval _.bind(@getAll, @, options), options.delay


  # Stop polling the resources API
  #
  stopPolling: () ->
    clearTimeout @timer
    delete @timer


  # Generate the API path to the resource based on the action
  path: (action, id, {parentResourcesKey, parentResourceId, query}={}) =>
    path = ''
    switch action
      when 'index', 'create' # nest if parent resource specified
        if parentResourcesKey?
          path += "/#{_.snakeCase parentResourcesKey}"
          path += "/#{parentResourceId}" if parentResourceId?
        path += "/#{_.snakeCase @resourcesKey}"
      else # shallow: show, update, destroy
        path += "/#{_.snakeCase @resourcesKey}"
        path += "/#{id}" if id?
    path


  getPath: (action, id, {parentResourcesKey, parentResourceId, query}={}) =>
    path = @path arguments...

    path += "?#{Utils.toQueryStr query}" if query?
    Store.API_PATH_PREFIX + path


  # Ajax wrapper
  #
  # @param url      [String]  API path generated by @getPath
  # @param verb     [String]  REST verb: GET, POST, PATCH, DELETE
  # @param data     [Object]  Request payload
  #
  # @return [Object] Promise
  ajax: (url, verb='GET', data) ->
    deferred = new RSVP.Promise (resolve, reject) ->
      # superagent's method name is 'del', not 'delete'
      verb = 'del' if verb is 'DELETE'
      req = superagent[verb.toLowerCase()] url

      req.set 'Content-Type', Store.DEFAULT_CONTENT_TYPE

      # append no-cache headers
      req.use superagentNoCache

      # use plugins
      for plugin in Store.SUPERAGENT_PLUGINS
        req.use plugin

      req.send data ? {}

      req.end (err, response) ->
        if response?.ok
          AppEvents.trigger 'api.networkok'
          resolve response.body
        else
          switch
            when response?.status in [401, 403, 404]
              AppEvents.trigger 'api.exception', response
            when response?.status in [422]
              # ignore for now (these are form errors usually)
            else
              AppEvents.trigger('api.networkerror', err) if err?
          reject response

    # return the RSVP promise object
    deferred

  # direct access to REST verbs
  get:    (url, data) -> @ajax url, 'GET', data
  index:  (url, data) -> @ajax url, 'GET', data
  post:   (url, data) -> @ajax url, 'POST', data
  update: (url, data) -> @ajax url, 'PATCH', data
  delete: (url, data) -> @ajax url, 'DELETE', data

  #
# mix the Events functions into the Store prototype
_.extend(Store::, Events)

# handle any uncaught errors in our Promise chain
RSVP.on 'error', (reason) ->
  # webkit and blink have different ways of logging the stack, so check for the Apple vendor string
  console.error(if navigator.vendor.indexOf('Apple') >= 0 then reason else reason.stack) if reason?

module.exports = Store
