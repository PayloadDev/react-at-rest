#Stores

##Overview

The `Store` class is responsible for:
* implementing the basic REST operations:
  * `getResource` (GET)
  * `getAll` (GET index)
  * `createResource` (POST)
  * `updateResource` (PATCH)
  * `destroyResource` (DELETE)

####Global Configuration

The Store class exposes some static variables to modify the default behaviour of the Store class (and all subclasses)

* `Store.API_PATH_PREFIX = [String]` - prefix all API requests with this string (default: '')
* `Store.API_ENVELOPE = [Bool]` - enable or disable enveloped API responses (default: true)
* `Store.SUPERAGENT_PLUGINS = [Array]` - an array of superagent plugin functions. See https://github.com/visionmedia/superagent#plugins (default: [])
  * useful for modifying HTTP headers to send auth tokens, etc.
* `Store.DEFAULT_CONTENT_TYPE = [String]` - Content type header (default: 'application/json')

###Constructor

```
new Store(
  String resourcesKey,
  (String resourceKey)
)
```

* `resourcesKey`: plural resource name for the API and data envelope. eg. for /api/v1/users this would be `"users"`
* `resourceKey`: singular resource name for GET by id envelope. Automatically derived from `resourcesKey` if not provided.
  * eg. if `resourcesKey` is 'users' then `resourceKey` will be automatically set to 'user'
  * pass this argument when the singular of your resource is not a simple conversion (eg. 'companies', 'company')

###REST Methods

####getAll()

```
getAll(
    (Object options)
)
```

* Retrieve all resources from an API index
* `options`:
  * `parentResourcesKey`:  Name of parent resource
  * `parentResourceId`:    Required if parentResourcesKey specified. Id of parent resource.
  * `query`:               Querystring object to pass onto the API for sort/filter/etc
  * `namespace`:           Namespace to use when returning data. Defaults to the resourcesKey.

**returns: Promise**

####getResource()

```
getResource(
    String id,
    (Object options)
)
```

* Retrieve all resources from an API index
* `id`: the resource's id
* `options`:
  * `query`: Querystring object to pass onto the API for sort/filter/etc
  * `cache`: Boolean. When true, returns the object from the internal cache if it is present there

**returns: Promise**

####createResource()

```
createResource(
    Object model,
    (Object options)
)
```

* Create a new resource
* `model`: the resource to create
* `options`:
  * `parentResourcesKey`: Name of parent resource
  * `parentResourceId`:   Required if parentResourcesKey specified. Id of parent resource.
  * `query`:              Querystring object to pass onto the API for sort/filter/etc

**returns: Promise**

####updateResource()

```
updateResource(
    String id,
    Object patch,
    (Object options)
)
```

* Update a specific resource
* `id`: the id of the resource
* `patch`: the changes to the resource
* `options`:
  * `query`:              Querystring object to pass onto the API for sort/filter/etc

**returns: Promise**

####destroyResource()

```
destroyResource(
    String id
)
```

* Destroy a specific resource
* `id`: the id of the resource

**returns: Promise**

###Store Customization

Stores provide several methods which are intended to be overridden in subclasses to suit your particular environment.

###path()

```
path(
  String action,
  (String id),
  (Object options)
)
```

* Generate an API path
* `action`: REST action. One of 'index', 'create', 'show', 'update', or 'destroy'
* `id`: resource id
* `options`:
  * `parentResourcesKey`: plural name of parent resource
  * `parentResourceId`: id of parent resource
  * `query`: query string

**returns: String**

###parseResource()

```
parseResource(
  Object data
)
```

* hook for parsing the returned singular data into the format expected by the application
* when overriding, return the modified data
* `data`: the raw JSON object returned by the API

**returns: Object**

###parseAll()

```
parseAll(
  Object data
)
```

* hook for parsing the returned index data into the format expected by the application
* when overriding, return the modified data
* `data`: the raw JSON object returned by the API

**returns: Object**

###Events

Stores trigger events when specific actions occurs. You can listen to a Store's events from a component by extending `EventableComponent`. The `DeliveryService` component automatically subscribes to Store events to manage data flow.

Event Name    | Triggered by      | Arguments
------------- | -------------     | ---------
reset         | getAll()          | Object resources
fetch         | getResource()     | Object resource
create        | createResource()  | Object resource
update        | updateResource()  | Object resource
destroy       | destroyResource() | Object resources

Additionally, Stores [trigger some global events on the AppEvents object](appevents.md).

### Merging and Chaining API Requests

A Store functions as an abstraction between the raw data coming from the API, and the data needed to present the UI. Typically this relationship is 1:1, meaning Resources in the client map to documents returned by the API. In some cases, though, it's necessary to chain or merge multiple API requests into a single object for the client to represent.

The Store class can be subclassed to chain multiple requests into a single Resource or Resource collection. This is accomplished by overriding the RESTful verb methods, making the necessary requests, and invisibly returning the merged object via the Store.

```coffeescript
# retrieves the company associated with the user and merges it into the user resource
class UserWithCompanyStore extends Store

  get: (url, options) ->
    response = {}

    @ajax url, 'GET', options
    .then (data) ->
      response = data

      CompanyStore.getResource data.user.companyId

    .then (data) ->
      response.user.company = data.company
      response
```
