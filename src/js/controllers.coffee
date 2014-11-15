module.exports = angular.module('app.controllers', [])

.controller 'MainCtrl',
['$scope', 'dataCache', 'Socrata',
($scope, dataCache, Socrata) ->

  $scope.config =
    disableClustering: false
    displayMode: 'markers'

  $scope.disableClustering = ->
    $scope.config.disableClustering = not $scope.config.disableClustering

  $scope.setMode = (mode) ->
    $scope.config.displayMode = mode
]

.controller 'MapCtrl',
['$scope', 'dataCache', 'Socrata',
($scope, dataCache, Socrata) ->
  ###
  map config
  ###
  $scope.center = [47.595312, -122.331606]

  $scope.crimeData = []

  ###
  get, parse, and cache crime data
  ###
  if dataCache.isCached()
    $scope.crimeData = dataCache.get()
  else
    Socrata.getData()
      .then (response) -> $scope.crimeData = response
      .catch (error) -> console.error error
]

.controller 'DataModalCtrl',
  ['$scope', 'dataPoint', '$modalInstance',
  ($scope, dataPoint, $modalInstance) ->
    $scope.dataPoint = dataPoint

    $scope.close = ->
      $modalInstance.dismiss 'cancel'
]

.controller 'ChartsCtrl',
['$scope', 'mapStats', 'dataCache', 'Socrata',
($scope, mapStats, dataCache, Socrata) ->
  if dataCache.isCached()
    data = mapStats.show()
    $scope.distanceData = data.distances
    $scope.crimeData = data.crimeTypes
  else
    Socrata.getData()
      .then ->
        data = mapStats.show()
        $scope.distanceData = data.distances
        $scope.crimeData = data.crimeTypes
      .catch (error) ->
        console.error error
]
