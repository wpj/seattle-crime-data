module.exports = angular.module('app.controllers', [])

.controller 'MainCtrl',
['$scope', 'mapStats', 'dataCache', 'Socrata',
($scope, mapStats, dataCache, Socrata) ->

  ###
  map config
  ###
  $scope.center = [47.595312, -122.331606]

  $scope.config =
    disableClustering: false
    displayMode: 'markers'

  $scope.crimeData = []

  $scope.disableClustering = ->
    $scope.config.disableClustering = not $scope.config.disableClustering

  $scope.setMode = (mode) ->
    $scope.config.displayMode = mode

  ###
  get, parse, and cache crime data
  ###
  Socrata.getData()
    .then (response) ->
      crimes = for record in response.data
        do (record) ->
          if coords = record.incident_location
            mapStats.compareDistance [parseFloat(coords.latitude), parseFloat(coords.longitude)]
            mapStats.extractCrimeTypes record.event_clearance_group
            record

      dataCache.set crimes
      $scope.crimeData = crimes
    
    .catch (error) ->
      console.error error
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
