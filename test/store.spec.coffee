superagent = require 'superagent'
mocker     = require('superagent-mocker')(superagent)

{Store}    = require '../modules'
expect     = require 'expect'

# Store.API_PATH_PREFIX = 'http://test.server'
# Store.SUPERAGENT_PLUGINS = [(request) ->
#   console.log 'whoops!', request
#   mocker(request)]

# set up mock API
#
#
#

describe 'Store', ->
  describe '#getPath()', ->
    it 'should return the correct API path', ->
      store = new Store 'users'
      expect(store.getPath 'index').toBe '/users'
      expect(store.getPath 'create').toBe '/users'
      expect(store.getPath 'show', 4).toBe '/users/4'
      expect(store.getPath 'update', 4).toBe '/users/4'

    it 'should return the correct nested API path', ->
      store = new Store 'addresses'
      options = parentResourcesKey: 'users', parentResourceId: '4'
      expect(store.getPath 'index', null, options).toBe '/users/4/addresses'
      expect(store.getPath 'show', 13, options).toBe '/addresses/13'

  describe '#getAll()', ->
    it 'should fetch an array from an index route', ->
      mocker.get '/users', (req) ->
        req.body = users: [{id: 1, name: 'bob'}, {id: 2, name: 'jim'}]
        req.ok = true
        req

      store = new Store 'users'
      store.getAll().then (data) ->
        expect(data.users[0].name).toBe 'bob'
        expect(data.users[1].name).toBe 'jim'

  describe '#getResource()', ->
    it 'should fetch a resource from an id route', ->
      mocker.get '/users/1', (req) ->
        req.body = user: {id: 1, name: 'bob'}
        req.ok = true
        req

      store = new Store 'users'
      store.getResource(1).then (data) ->
        expect(data.user.name).toBe 'bob'

    it 'should fail on a bad API response', ->
      mocker.get '/users/1', (req) ->
        req.body = 'blorp'
        req.ok = true
        req

      store = new Store 'users'
      store.getResource(1).catch (err) ->
        expect(err).toBeA Error

