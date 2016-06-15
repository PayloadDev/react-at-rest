# RestForm component

## Overview

The RestForm component is a React component that you can extend to build forms.

It is responsible for:
* setting the form state through the `model`.
* tracking changes to the model through the `patch`.
* capturing the form submit event and routing the request through to the API
* pre-validating form fields
* capturing and displaying error messages returned from the server

## Rendering a RestForm

A subclassed RestForm will typically render a `<form>` element. RestForm provides helper methods for capturing keystrokes and submit events from the form.

A RestForm component has one or more RestFormElement children which constitute the HTML input elements. It's also trivial to subclass RestFormElement and build your own inputs, such as date/time pickers, tagfields, etc.

RestForm provides a helper method (`getFieldProps`) for passing required props to RestFormElements.

### Sample Code

```coffeescript
class UserForm extends RestForm

  render: ->
    <form onSubmit={@handleSubmit}>
      <Forms.TextInput {...@getFieldProps('name')} />
      <Forms.TextAreaInput {...@getFieldProps('profile')} />
      <button>Save</button>
    </form>


class UserPage extends React.Component

  constructor: ->
    @userStore = new Store('users')

  handleSuccess: (user) ->
    window.location = "/users/#{user.id}"

  render: ->
    <UserForm
      model={name: 'Bob', profile: 'Comedy genius.'}
      store={@userStore}
      onSuccess={@handleSuccess} />
```

## Props

#### model (Object)

The initial data for the form. When creating new Resources, this is typically an empty object. When updating an existing object, this is the object to update.

```coffeescript
# create a user
<UserForm model={{}} />
# update a user
<UserForm model={@state.user} />
```

#### store (Store)

The [Store](store.md) to use for this Resource.

#### onSuccess (Function)

Method called when the API call succeeds. Passes the new model as an argument.
```
handleSuccess: (data) ->
```

#### onChange (Function)

Method called when the form data (the patch) changes. Passes the patch and the updated model as arguments.

```
handleChange: (patch, model) ->
  console.log patch
  # {name: 'Bob O.'}
  console.log model
  # {name: 'Bob O.', profile: 'Comedy genius.'}
```

## RestForm Methods

#### getFieldProps()
```
getFieldProps(
    String key
)
```
* Creates an object representing spread props to pass to the RestFormElement child component
* `key`: the property name in the model for this RestFormElement to update

#### getUpdatedModel()
```
getUpdatedModel()
```
* Merge the patch and original model into a new model object

**Returns: Object**

## Configuration

#### validations (Object)

The `validations` object maps field names to client-side validations. It currently supports:
* `required`: Boolean. Set if the field is required to have a value.
* `regexp`: RegularExpression. The field value must match the expression.
* `func`: Function. Custom validation method, called as func(value). Should return false when invalid.
* `message`: String. The custom error message to display when the field fails validation.

Validations are executed and must pass prior to submitting anything to the API.

#### omitAttributes (Array)

Field names which should **not** but submitted as part of the patch to the API. Useful for transient fields which affect the UI but shouldn't be sumitted to the server.
```
omitAttributes: ['acceptAgreement', 'viewedTermsAndConditions']
```

### Handling Errors

RestForm expects errors to be returned in the following JSON format:
{
  errorMessage: 'Global Error Message String',
  errors: {
    fieldName: [Array of Error Message Strings]
  }
}

If the API does not conform to this format, override the `parseErrors: (body)` method, parse the errors, and return an object in the expected format.


