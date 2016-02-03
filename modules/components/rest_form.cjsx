# Common Form functionality for RESTful APIs
#
Utils              = require '../utils'
EventableComponent = require './eventable_component'
Resource           = require '../resource'
AppEvents          = require '../app_events'

React = require 'react'
RSVP  = require 'rsvp'

_ =
  cloneDeep: require 'lodash/lang/cloneDeep'
  extend:    require 'lodash/object/extend'
  get:       require 'lodash/object/get'
  isEmpty:   require 'lodash/lang/isEmpty'
  isEqual:   require 'lodash/lang/isEqual'
  omit:      require 'lodash/object/omit'
  set:       require 'lodash/object/set'


module.exports = class RestForm extends EventableComponent

  @propTypes =
    model:     React.PropTypes.object
    store:     React.PropTypes.object
    onChange:  React.PropTypes.func
    onSuccess: React.PropTypes.func

  @contextTypes =
    history:  React.PropTypes.object
    location: React.PropTypes.object

  # array of attribute names which will never be submitted in a CREATE/UPDATE API request
  # useful for forms which use transient fields for UI that aren't meant to be part of the model
  omitAttributes: []

  # client side validations
  # object property is the name of the model's property to validate
  # possible validations are:
  #    required:  bool                (allow empty, also show required flag in UI)
  #    regexp:    RegularExpression   (reg exp to validate against)
  #    fieldName: string              (alternate fieldname to use in the errors object)
  #
  # eg. name:
  #       required: true
  #     amount:
  #       regexp: /^\d*$/
  validations: {}


  constructor: (props) ->
    @state =
      busy:         false
      errorMessage: null
      errors:       {}
      patch:        {}


  # Attach lock_version to the model's patch payload
  componentDidMount: ->
    @setLockVersion @getUpdatedModel()


  # Update form state if a new model is passed to it
  #
  componentWillReceiveProps: (nextProps) ->
    @setLockVersion nextProps.model
    @setState (state) ->
      errors: nextProps.errors ? state.errors


  # Scroll to first error when rendering a form with errors
  componentDidUpdate: (prevProps, prevState) ->
    if @hasNewErrors @state, prevState
      error = document.getElementsByClassName 'has-error'
      error[0]?.scrollIntoView()


  # get the current state of the model with pending changes applied
  getUpdatedModel: ->
    attrs = if @props.model instanceof Resource then @props.model.attributes else @props.model
    _.extend {}, attrs, _.cloneDeep(@state.patch)


  # Detect if new errors have been rendered
  hasNewErrors: (state, prevState) ->
    not _.isEmpty(state.errors) and not _.isEqual(prevState.errors, state.errors)


  # Set model lock version if updating a model that uses optimistic locking
  #
  setLockVersion: (model) ->
    if model?.lockVersion?
      @handleFieldChange 'lockVersion', model.lockVersion


  # Updates a field in the form's state's patch object which will be
  # submitted to the API. Called when a field's value changes in the UI
  #
  # @param key   [String] the model's property name
  # @param value [String] value to set on the property
  #
  # @return [Promise(state)]
  #
  handleFieldChange: (key, value) =>
    promise = new RSVP.Promise (resolve, reject) =>
      @setState (state, props) ->
        patch: _.set state.patch, key, value
      , ->
        # notify any listeners of the form's change
        @props.onChange?(@state.patch, @getUpdatedModel(), @)
        resolve @state


  # Delegate form submission to save method
  #
  handleSubmit: (e) =>
    e.preventDefault()
    e.stopPropagation()
    @saveModel()


  # Delegate API create/update to store designated by form's props
  #
  saveModel: (validate=true) =>
    return if @state.busy

    model = @getUpdatedModel()

    # validate the model
    errors = @validateModel model if validate
    return if errors?

    # a model with an id exists already, so we issue a patch
    if model.id?
      # ignore empty updates
      if _.isEmpty @state.patch
        @props.onSuccess?()
        return
      deferred = @props.store.updateResource model.id, _.omit(@state.patch, @omitAttributes), @props.options
    # otherwise create a new resource
    else
      deferred = @props.store.createResource _.omit(model, @omitAttributes),
        parentResourceId:   @props.parentResourceId
        parentResourcesKey: @props.parentResourcesKey
        query:              @props.options?.query

    # set busy state
    @setState busy: true

    deferred
      .then (data) =>
        @setState busy: false
        AppEvents.trigger 'form.error', {}
        @props.onSuccess?(data)
      .catch(@handleErrors)


  # Destroys a model on the server via API
  #
  handleDestroy: (e) =>
    e.preventDefault()
    @props.store.destroyResource(@getUpdatedModel().id)
      .then(@props.onDestroy)


  # Update form state with resource errors or general error messaging on submit failure:
  #   When resource errors, fields will be highlighted and appended with error text.
  #   When error message, error willd isplay in an embedded ErrorSummary component.
  #
  # @param response [Object] error response. could be an xhr object for xhr errors, or a generic Error object
  #
  handleErrors: (response) =>
    @setState busy: false

    if response.body?
      if response.body.errors
        @setState (state) ->
          state.errors = {}
          # error might be in dotted notation, so convert that to a nested object for subforms
          for key,value of response.body.errors
            _.set(state.errors, key, Utils.capitalize e for e in value)
          state.errorMessage = null
          state
      else if response.body.errorMessage
        @setState errorMessage: response.body.errorMessage

      AppEvents.trigger 'form.error',
        errors:       response.body.errors
        errorMessage: response.body.errorMessage

    else
      console.error response.stack ? response ? 'An unknown error occurred.'


  # validate the outgoing model against @validations
  validateModel: (model, validations) ->
    errors = null
    for name, validation of (validations ? @validations)
      modelValue = _.get model, name
      if validation.required and (not modelValue? or modelValue is '' or modelValue.length is 0)
        errors ?= {}
        _.set errors, validation.fieldName ? name, ['Can\'t be blank']
      if modelValue? and validation.regexp?.test(modelValue) is false
        errors ?= {}
        _.set errors, validation.fieldName ? name, ['Invalid entry']

    AppEvents.trigger 'form.error', errors: errors
    @setState errors: errors
    errors


  # Attach to the form's onKeyPress event to prevent the form from submitting
  # when the user presses Enter
  # eg. <form onSubmit={@handleSubmit} onKeyPress={@preventSubmit}>
  #
  preventSubmit: (e) ->
    e.preventDefault() if e.which is 13 and e.target.type isnt 'textarea'


  # Shortcut for generating props passed to JSX on the form elements
  #
  # @param key [String] the model's property name
  #
  getFieldProps: (key) =>
    name:      key
    value:     _.get @getUpdatedModel(), key
    errors:    _.get @state.errors, key
    onChange:  @handleFieldChange
    required:  @validations[key]?.required
