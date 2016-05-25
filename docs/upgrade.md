# React-at-Rest Upgrade Guide

## Upgrading from 1.x to 2.0

The 2.0 release mostly addresses internal code cleanliness, but some potentially breaking changes exist.

### DeliveryService
The data binding methods no longer take a callback function. The method signature is now
```
subscribeAll(
    Object store,
    (Object options)
)
```
React-at-Rest 2.0 will accept the old signature, but throws a warning in the console.

If you desire custom behaviour after data loads, it's recommended to override `setStateFromStore` in a Store subclass, or listen to the data [Events](deliveryservice.md#events) on the store directly.

### Store

`denormalizeResource` and `denormalizeAll` have been renamed `parseResource` and `parseAll` respectively to better reflect the capabilities of these methods.

In 1.x the Store implemented an overly specific strategy for parsing Policies (permissions) from an API response. The default behaviour for `getPolicies()` is to return null, and can be overridden in a Store subclass (or attached to Store.prototype directly).
```
Store::getPolicies = (data, id) ->
  # custom Policy parsing here
  # return a Policy object in the format {update: true, delete: false}
```


### Resource
In 2.0 Resource objects no longer maintain an `.attributes` property containing all the object's properties (this was created to simplify object cloning). Resources can now be cleanly cloned or enumerated without having to reference `.attributes`.

This was mostly used internally.
