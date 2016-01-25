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
        req.body = users: [{id: 1, name: 'bob'}, {id: 2, name: 'jim'}]
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
