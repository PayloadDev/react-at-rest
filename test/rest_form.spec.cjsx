React        = require 'react'
superagent   = require 'superagent'
mocker       = require('superagent-mocker')(superagent)
expect       = require 'expect'
TestUtils    = require 'react-addons-test-utils'

{Store, RestForm, Forms} = require '../modules'

class UserForm extends RestForm
  validations:
    name:
      required: true
  render: ->
    <form onSubmit={@handleSubmit} ref='form'>
      <Forms.TextInput {...@getFieldProps('name')} ref='textInput' />
      <button ref='submitButton'>Submit</button>
    </form>


describe 'RestForm', ->
  store = new Store 'users'

  describe '#handleFieldChange', ->
    before ->
      @component = TestUtils.renderIntoDocument <UserForm model={{bing: 'bong'}} store={store} />

    it 'should update the patch on user action', ->
      input = @component.refs.textInput.refs.element
      input.value = 'test data'
      TestUtils.Simulate.change input
      expect(@component.state.patch).toEqual name: 'test data'
      expect(@component.getUpdatedModel()).toEqual
        name: 'test data'
        bing: 'bong'

  describe '#saveModel', ->
    before ->
      mocker.post '/users', (req) ->
        req.body = user: req.body
        req.body.user.id = 99
        req.ok = true
        req

    it 'should capture the submit event and save via Store', (done) ->
      # check onSuccess callback returned with data from Store
      successSpy = expect.createSpy().andCall (data) ->
        expect(successSpy).toHaveBeenCalled()
        expect(data.user).toInclude { bing: 'bong', name: 'test data', id: 99 }
        done()

      component = TestUtils.renderIntoDocument <UserForm
        onSuccess={successSpy}
        model={{bing: 'bong'}}
        store={store} />

      input = component.refs.textInput.refs.element
      input.value = 'test data'
      TestUtils.Simulate.change input
      expect(component.state.patch).toEqual name: 'test data'

      spy         = expect.spyOn(component, 'saveModel').andCallThrough()
      validateSpy = expect.spyOn(component, 'validateModel').andCallThrough()

      TestUtils.Simulate.submit component.refs.form
      expect(spy).toHaveBeenCalled()
      expect(validateSpy).toHaveBeenCalled()

    it 'should validate the patch', ->
      component = TestUtils.renderIntoDocument <UserForm
        model={{bing: 'bong'}}
        store={store} />

      validateSpy = expect.spyOn(component, 'validateModel').andCallThrough()
      TestUtils.Simulate.submit component.refs.form

      # validations should not pass
      expect(validateSpy).toHaveBeenCalled()
      expect(component.state.errors).toEqual { name: [ "Can't be blank" ] }

      # now validations should pass
      component.state.patch = name: 'test data'
      TestUtils.Simulate.submit component.refs.form
      expect(validateSpy).toHaveBeenCalled()
      expect(component.state.errors).toNotExist()



