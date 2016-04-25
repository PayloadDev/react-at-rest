# DeliveryService component

## Overview

The DeliveryService component is a React component that you can extend to manage loading of one or more resources via a Store.

It is responsible for:
* binding the Store to the component
* managing the loading state
* periodically refreshing the data from the API (optional)
* intelligently rebinding the API query parameters when the URL changes (for searching, sorting, etc)

## The DeliveryService Lifecycle

When a DeliveryService subclass is mounted, several custom lifecycle methods are called.

* **Initial state:** `@state.loaded` is false, indicating no data has been loaded
* **bindResources** is called. Here you will bind one or more Stores to the component using the [binding methods](#bindings).
  * before the API calls are made, `resourcesWillLoad()` is called
  * as each bound resource returns data, `setStateFromStore()` is called, attaching the resources and metadata to `@state`
* **resourcesDidLoad** is called
* **Loaded state:** `@state.loaded` is true

### Sample code

DeliveryService is best understood through a simple sample class:
```coffeescript
class UserIndexPage extends DeliveryService

  bindResources: (props) ->
    # get all the users
    @subscribeAll UserStore
    # get some company data. the company id could come from anywhere (current session, etc)
    @retrieveResource CompanyStore, null,
      id: 1
      query: props.location.query # pass the query string, assuming we're using react-router

  render: ->
    return <Loading /> unless @state.loaded

    rows = for user in @state.users
      <UserRow key={user.id} user={user} />

    <div>
      {rows}
      Showing {@state.userMeta.pageSize} records of {@state.userMeta.total}
    </div>
```

## Refetching Data

Data is refetched during the `componentWillReceiveProps` React lifecycle method. DeliveryService tries to be somewhat smart about this,
especially if the component is a Route (when using React-Router). However, it is possible that the default behaviour will result in excessive
data reloads for your particular project.

In this case, you can extend `componentWillReceiveProps` to check for the specific changes which should result in rebinding for your app.

```coffeescript
componentWillReceiveProps: (nextProps) ->
  super nextProps if nextProps.dataId isnt @props.dataId
```

## Binding Methods
#### subscribeAll()

```
subscribeAll(
    Object store,
    (Function callback),
    (Object options)
)
```
* Retrieve all Resources from the API. Refetch the resources every 15 seconds and update the component's state.
* `store`: the Store to use
* `callback`: By default, bound to the internal class method `setStateFromStore`. A custom callback can be supplied but is usually uncessary unless you require specific behavour after the data has been loaded.
* `options`:
  * `parentResourcesKey`: Name of parent resource
  * `parentResourceId`:   Required if parentResourcesKey specified. Id of parent resource.
  * `query`:              Querystring object to pass onto the API for sort/filter/etc


#### subscribeResource()

```
subscribeResource(
    Object store,
    (Function callback),
    (Object options)
)
```
* Retrieve the Resource from the API. Refetch the resource every 15 seconds and update the component's state.
* `store`: the Store to use
* `callback`: By default, bound to the internal class method `setStateFromStore`. A custom callback can be supplied but is usually uncessary unless you require specific behavour after the data has been loaded.
* `options`:
  * `id`:                 id of the resource
  * `parentResourcesKey`: Name of parent resource
  * `parentResourceId`:   Required if parentResourcesKey specified. Id of parent resource.
  * `query`:              Querystring object to pass onto the API for sort/filter/etc

#### retrieveAll()

```
retrieveAll(
    Object store,
    (Function callback),
    (Object options)
)
```
* Retrieve all Resources from the API.
* `store`: the Store to use
* `callback`: By default, bound to the internal class method `setStateFromStore`. A custom callback can be supplied but is usually uncessary unless you require specific behavour after the data has been loaded.
* `options`:
  * `parentResourcesKey`: Name of parent resource
  * `parentResourceId`:   Required if parentResourcesKey specified. Id of parent resource.
  * `query`:              Querystring object to pass onto the API for sort/filter/etc

#### retrieveResource()

```
retrieveResource(
    Object store,
    (Function callback),
    (Object options)
)
```
* Retrieve the Resource from the API.
* `store`: the Store to use
* `callback`: By default, bound to the internal class method `setStateFromStore`. A custom callback can be supplied but is usually uncessary unless you require specific behavour after the data has been loaded.
* `options`:
  * `id`:                 id of the resource
  * `parentResourcesKey`: Name of parent resource
  * `parentResourceId`:   Required if parentResourcesKey specified. Id of parent resource.
  * `query`:              Querystring object to pass onto the API for sort/filter/etc

## Configuration

A DeliveryService subclass can be configured via a few utility constants.

#### defaultQuery: (object or function)

Append a default query to every request. If `defaultQuery` is a function, it will be called with the signature `(store) ->`. If it is an object, that query will be appended to every request from the component regardless of origin.

```coffeescript
# all queries appended with ?sort=asc
defaultQuery:
  sort: 'asc'

# queries appended depending on originating store
defaultQuery: (store) ->
  if (store is @userStore)
    sort: 'asc'
  else
    sort: 'desc'
```

#### routeParamKey: (string)

When using React-at-Rest with react-router, DeliveryService will intelligently rebind all the resources when a dynamic route parameter changes. This allows the data to be refetched without rerendering the entire page.

`routeParamKey` should be set to the dynamic route key declared in the `<Route>`.

For example, if you have a route declared as `/users/:userId`, and the user navigates from `/users/3` to `/users/9`, DeliveryService will refetch the User with the new id.

Set `routeParamKey: 'userId'` in this case.
