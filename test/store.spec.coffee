superagent = require 'superagent'
mocker     = require('superagent-mocker')(superagent)
expect     = require 'expect'
_          = require 'lodash'

{Store, Resource} = require '../modules'


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
      spy   = expect.createSpy()
      store.on 'reset', spy

      store.getAll().then (data) ->
        expect(data.users[0].name).toBe 'bob'
        expect(data.users[1].name).toBe 'jim'
        expect(spy).toHaveBeenCalled()

    it 'should store metadata returned in the API', ->
      mocker.get '/users', (req) ->
        req.body = users: [{id: 1, name: 'bob'}, {id: 2, name: 'jim'}], meta: total: 2
        req.ok = true
        req

      store = new Store 'users'

      store.getAll().then (data) ->
        expect(store.resources.meta.total).toBe 2


  describe '#getResource()', ->
    it 'should fetch a resource from an id route', ->
      mocker.get '/users/1', (req) ->
        req.body = user: {id: 1, name: 'bob'}
        req.ok = true
        req

      store = new Store 'users'
      spy   = expect.createSpy()
      store.on 'fetch', spy
      store.getResource(1).then (data) ->
        expect(data.user.name).toBe 'bob'
        expect(spy).toHaveBeenCalled()

    it 'should fail on a bad API response', ->
      mocker.get '/users/1', (req) ->
        req.body = 'blorp'
        req.ok = true
        req

      store = new Store 'users'
      spy   = expect.createSpy()
      store.on 'fetch', spy
      store.getResource(1).catch (err) ->
        expect(err).toBeA Error
        # spy should not have been called
        expect(spy.calls.length).toEqual 0

    it 'should store the resource with any policies', ->
      mocker.get '/users/1', (req) ->
        req.body =
          user: {id: 1, name: 'bob'}
          meta: policies: {update: true, destroy: false}
        req.ok = true
        req

      store = new Store 'users'
      # create a getPolicies method
      store.getPolicies = (data, id) ->
        data.meta?.policies

      store.getResource(1).then (data) ->
        expect(data.user.canUpdate()).toBe true
        expect(data.user.canDestroy()).toBe false

  describe '#createResource()', ->
    it 'should create a resource', ->
      mocker.post '/users', (req) ->
        req.body = user: req.body
        req.body.user.id = 99
        req.ok = true
        req

      store = new Store 'users'
      spy   = expect.createSpy()
      store.on 'create', spy

      store.createResource(name: 'bob').then (data) ->
        expect(data.user.name).toBe 'bob'
        expect(data.user.id).toBe 99
        expect(spy).toHaveBeenCalled()

  describe '#deleteResource()', ->
    it 'should delete a resource', ->
      mocker.del '/users/99', (req) ->
        req.ok = true
        req

      store = new Store 'users'
      spy   = expect.createSpy()
      store.on 'destroy', spy

      store.destroyResource(99).then (data) ->
        expect(spy).toHaveBeenCalled()

  describe '#storeResource()', ->
    it 'should cache the API resources', ->
      store = new Store 'users'
      store.storeResource id: 99, name: 'bob'
      expect(store.resources.users.length).toBe 1
      expect(store.resources.users[0]).toBeA Resource
      expect(store.resources.users[0].name).toBe 'bob'
