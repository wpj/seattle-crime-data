# third party modules
angularAnimate       = require 'angular-animate'
angularFoundation    = require 'angular-foundation'
uiRouter             = require 'angular-ui-router'

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
    'ui.router'
  ]
)

.config ['$stateProvider', '$urlRouterProvider',
  ($stateProvider, $urlRouterProvider) ->

    $stateProvider
      .state 'home',
        url: '/'
        templateUrl: 'home.html'
        controller: 'MapCtrl'

      .state 'charts',
        url: '/charts'
        templateUrl: 'charts.html'
        controller: 'ChartsCtrl'

      .state 'about',
        url: '/about'
        templateUrl: 'about.html'

    $urlRouterProvider.otherwise '/'
]
