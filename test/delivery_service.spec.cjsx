React        = require 'react'
superagent   = require 'superagent'
mocker       = require('superagent-mocker')(superagent)
expect       = require 'expect'
TestUtils    = require 'react-addons-test-utils'

{Store, DeliveryService} = require '../modules'

describe 'DeliveryService', ->
  store = new Store 'users'

  describe '#render()', ->
    before ->
      mocker.get '/users', (req) ->
        req.body = users: [{id: 1, name: 'bob'}, {id: 2, name: 'david'}]
        req.ok = true
        req

    it 'should render in an unloaded state', ->
      class UserTestPage extends DeliveryService
        render: ->
          return <div /> unless @state.loaded
          <h1 />

      component = TestUtils.renderIntoDocument <UserTestPage />
      expect(component.state.loaded).toBe false
      expect(TestUtils.findRenderedDOMComponentWithTag component, 'div').toExist()

  describe '#resourcesDidLoad()', ->
    it 'should retrieve bound data', (done) ->
      class UserTestPage extends DeliveryService
        bindResources: ->
          @retrieveAll store
        resourcesDidLoad: ->
          expect(component.state.loaded).toBe true
          expect(component.state.users).toExist()
          expect(component.state.users.length).toBe 2
          done()
        render: ->
          return <div /> unless @state.loaded
          <h1 />

      component = TestUtils.renderIntoDocument <UserTestPage />

  describe '#mungeArgs()', ->
    it 'should detect a null first argument', ->
      spy = expect.spyOn console, 'error'
      options = DeliveryService::mungeArgs [null, {company: 'GloboChem'}]
      expect(spy).toHaveBeenCalled()
      expect(options).toEqual {company: 'GloboChem'}
      expect.restoreSpies()

    it 'should return options when there is 1 argument', ->
      options = DeliveryService::mungeArgs [{company: 'GloboChem'}]
      expect(options).toEqual {company: 'GloboChem'}

    it 'should return null when there is a single null argument', ->
      options = DeliveryService::mungeArgs [null]
      expect(options).toEqual null

