require 'coffee-react/register'

{jsdom} = require('jsdom')
expect  = require('expect')

global.document  = jsdom('<!doctype html><html><body></body></html>')
global.window    = document.defaultView
global.navigator = global.window.navigator
global.self      = document.defaultView

# global.XMLHttpRequest = require('sinon').useFakeXMLHttpRequest()
