module.exports = angular.module('app.controllers', [])

.controller 'MainCtrl', ['$scope', ($scope) ->
  $scope.center = [47.595312, -122.331606]

  $scope.config =
    disableClustering: false
    displayMode: 'markers'

  $scope.disableClustering = ->
    $scope.config.disableClustering = not $scope.config.disableClustering

  $scope.setMode = (mode) ->
    $scope.config.displayMode = mode
]

.controller 'MapCtrl', ['$scope', ($scope) ->

]

.controller 'DataModalCtrl',
  ['$scope', 'dataPoint', '$modalInstance',
  ($scope, dataPoint, $modalInstance) ->
    $scope.dataPoint = dataPoint

    $scope.close = ->
      $modalInstance.dismiss 'cancel'
]

.controller 'ChartsCtrl', ['$scope', 'mapStats', ($scope, mapStats) ->
  data = mapStats.show()
  $scope.distanceData = data.distances
]
