module.exports = angular.module('app.services', [])

.factory 'Socrata', ['$http', ($http) ->
  stadiumCoords =
    lat: 47.595312
    lng: -122.331606
    
  mileInMeters = 1609

  query =
    # $limit: 5000
    $where: "within_circle(incident_location, #{stadiumCoords.lat}, #{stadiumCoords.lng}, #{mileInMeters})"

  getData: ->
    $http.get "http://data.seattle.gov/resource/3k2p-39jp.json",
      params: query
]
