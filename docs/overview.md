# React-at-Rest Overview

React-at-Rest is designed to make working with REST-compliant APIs simple and relatively effortless. It provides components for consuming and creating RESTful resources and managing data flow through a single-page application.

React-at-Rest is *opinionated* about how your API should be structured, but is configurable and flexible enough to adapt to the real world. 

## RESTful APIs

React-at-Rest prefers *enveloped* APIs for a variety of reasons, but principally because enveloped APIs make it easier to implements metadata and to sideload related resources.

An enveloped API returns the requested resource wrapped in an object using the resource name as a key. For example:
```coffeescript
GET /users/1
# enveloped API would return
{ user: { id: 1, name: 'Bob' } }
# a bare API would return
{ id: 1, name: 'Bob' } 
```
Enveloped APIs are useful for sideloading, if for example you want to return the company information associated with a user in a single request:
```coffeescript
GET /users/1
{ 
  user: { id: 1, name: 'Bob', companyId: 2 },
  company: { id: 2, name: 'GloboChem' }
}
```
React-at-Rest Stores provide denormalization hooks for transforming these related resources into a single nested object if desired. More on this later.

Enveloped APIs also make it easier to return metadata, such as pagination information:
```coffeescript
GET /users
{
  users: [{ id: 1, name: 'Bob' }, { id: 2, name: 'David' }],
  meta: { totalCount: 2, perPage: 10 }
}
```
React-at-Rest automatically parses and stores metadata when returned in this manner.

API envelope behaviour can be turned off by setting `Store.API_ENVELOPE = false`. 

For consistency React-at-Rest will always return enveloped objects from Stores, even if `API_ENVELOPE` is turned off.

## Inheritance

React-at-Rest uses *inheritance* instead of mixins or composition. To implement your app, you'll be extending the basic React-at-Rest components and classes to implement your functionality. In both CoffeeScript and ES6, this is accomplished using the `extends` keyword. It's valuable to read the [example projects](https://github.com/PayloadDev/react-at-rest-examples) source code to see how React-at-Rest apps are built. 

# Core Classes

React-at-Rest is comprised of three fundamental building blocks:
* [Store](store.md)
* [DeliveryService](deliveryservice.md)
* [RestForm](restform.md)

and two associated concepts:
* [Resources](resources.md)
* [Events](events.md)

