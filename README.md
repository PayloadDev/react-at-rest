# react-at-rest
An opinionated framework for building web applications using React and RESTful APIs.

# Sample Projects

Clone the react-at-rest examples repo to get started! https://github.com/PayloadDev/react-at-rest-examples

# Main Concepts

* ReactAtRest is composed of 3 main classes, working in concert: `Store`, `DeliveryService`, and `RestForm`. 
  * `Store`: manages all AJAX requests and holds the data returned by the server.
  * `DeliveryService`: React Component that manages and simplifies communication with the Stores.
  * `RestForm`: React Component for building forms and managing RESTful data flow.
* Written in CoffeeScript, fully compatible with ES6.
* Uses subclasses instead of mixins or composition.
* Plays nicely with react-router

Requirements
---

`react` and `lodash`

