module.exports = angular.module('app.directives', [])

module.exports = angular.module('app.directives', [])

.directive 'collisionMap', ['Socrata', '$modal', (Socrata, $modal) ->
  restrict: 'E'
  templateUrl: 'collision-map.html'
  # replace: true
  scope:
    center: '='
    options: '='
  link: (scope, elem, attrs) ->

    ###
    map initialization
    ###
    map = L.map elem[0]
    map.setView scope.center, 14

    L.tileLayer 'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    .addTo(map)

    clusterLayer = new L.MarkerClusterGroup(disableClusteringAtZoom: 15)
    markersLayer = L.layerGroup()


    setMarkers = ->
      Socrata.getData()
        .then (response) ->
          console.log response
          records = response.data
          for record in records
            do (record) ->
              if coords = record.incident_location
                marker = L.marker([coords.latitude, coords.longitude])

                marker.addTo clusterLayer
                marker.addTo markersLayer

                marker.on 'click', (e) ->
                  $modal.open
                    templateUrl: 'data-modal.html'
                    controller: 'DataModalCtrl'
                    resolve:
                      dataPoint: -> record

          # map.addLayer clusterLayer
        .catch (error) ->
          console.log error

    ###
    event listeners, $watches, view updates
    ###

    scope.$watch 'center', ->
      map.setView scope.center

    scope.$watch 'options.disableClustering', (newVal, oldVal) ->
      if newVal
        map.removeLayer(clusterLayer)
        map.addLayer(markersLayer)
      else
        map.removeLayer(markersLayer)
        map.addLayer(clusterLayer)

    setMarkers()
]
