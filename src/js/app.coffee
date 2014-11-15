# third party modules
angularAnimate       = require 'angular-animate'
angularFoundation    = require 'angular-foundation'

# app modules
appControllers       = require './controllers'
appServices          = require './services'
appDirectives        = require './directives'

module.exports = angular.module('codingExercise',
  [
    'app.controllers'
    'app.services'
    'app.directives'
    'app.templates'
    'mm.foundation'
    'ngAnimate'
  ]
)
