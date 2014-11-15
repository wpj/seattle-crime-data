module.exports = angular.module('app.services', [])

.factory 'Socrata', ['$http', 'moment', ($http, moment) ->
  stadiumCoords =
    lat: 47.595312
    lng: -122.331606
    
  mileInMeters = 1609

  oneMonthAgo = moment().subtract(1, 'month').toISOString()

  query =
    $limit: 5000
    $where: "at_scene_time>'#{oneMonthAgo}' AND within_circle(incident_location,#{stadiumCoords.lat},#{stadiumCoords.lng},#{mileInMeters})"

  getData: ->
    $http.get "http://data.seattle.gov/resource/3k2p-39jp.json",
      params: query
]

.factory 'moment', ->
  moment = require 'moment'

.factory 'd3', ->
  d3 = require 'd3'
