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

## Binding Methods
#### subscribeAll()

#### subscribeResource()

#### retrieveAll()

#### retrieveResource()
