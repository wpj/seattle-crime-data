module.exports = angular.module('app.controllers', [])

.controller 'MainCtrl', ['$scope', ($scope) ->
  $scope.center = [47.595312, -122.331606]

  $scope.config =
    disableClustering: false

  $scope.disableClustering = ->
    $scope.config.disableClustering = not $scope.config.disableClustering
]

.controller 'DataModalCtrl',
  ['$scope', 'dataPoint', '$modalInstance',
  ($scope, dataPoint, $modalInstance) ->
    $scope.dataPoint = dataPoint

    $scope.close = ->
      $modalInstance.dismiss 'cancel'
]