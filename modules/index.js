module.exports = {
  // stores & resources
  AppEvents: require('./app_events'),
  Resource:  require('./resource'),
  Store:     require('./store'),

  // forms & components
  EventableComponent: require('./components/eventable_component'),
  DeliveryService:    require('./components/delivery_service'),
  RestFormElement:    require('./components/rest_form_element'),
  RestForm:           require('./components/rest_form'),
  Forms:              {
    CheckboxInput: require('./components/forms/checkbox_input'),
    ErrorSummary:  require('./components/forms/error_summary'),
    EmailInput:    require('./components/forms/email_input'),
    FieldErrors:   require('./components/forms/field_errors'),
    FieldHint:     require('./components/forms/field_hint'),
    FieldWrapper:  require('./components/forms/field_wrapper'),
    Label:         require('./components/forms/label'),
    NumberInput:   require('./components/forms/number_input'),
    PasswordInput: require('./components/forms/password_input'),
    RadioInput:    require('./components/forms/radio_input'),
    SelectInput:   require('./components/forms/select_input'),
    SubForm:       require('./components/forms/subform'),
    SubFormArray:  require('./components/forms/subform_array'),
    TextInput:     require('./components/forms/text_input'),
    TextAreaInput: require('./components/forms/textarea_input'),
  },

  // libs & utilities
  Events: require('../vendor/events'),
  Utils:  require('./utils'),

  superagent: require('superagent'),
  RSVP: require('rsvp')

};
