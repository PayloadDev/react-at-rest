## AppEvents

React-at-Rest uses a global AppEvents object which can be useful for updating your app based on global events.

You can use AppEvents anywhere in your app with a simple `{AppEvents} = require('react-at-rest')`.

#### Global Events

Event Name              | Triggered on                   | Arguments
-------------           | -------------                  | ---------
api.networkok           | successful network response    |
api.networkerror        | network connection error       | Error error
api.exception           | API error code response        | Object response
form.error              | Form validation error          | Object error

