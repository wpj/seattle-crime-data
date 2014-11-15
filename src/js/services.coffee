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

.factory 'mapStats', ->
  within =
    quarterMile: 0
    halfMile: 0
    threeQuarterMile: 0
    mile: 0

  crimeTypes = {}

  stadiumCoords = L.latLng [47.595312, -122.331606]

  compareDistance = (coords) ->
    distance = stadiumCoords.distanceTo(coords)

    if distance < 402
      within.quarterMile++
    else if distance < 804
      within.halfMile++
    else if distance < 1207
      within.threeQuarterMile++
    else
      within.mile++

  extractCrimeTypes = (crime) ->
    if crime of crimeTypes
      crimeTypes[crime]++
    else
      crimeTypes[crime] = 1

  compareDistance: compareDistance
  extractCrimeTypes: extractCrimeTypes
  show: ->
    distances: within
    crimeTypes: crimeTypes

.factory 'moment', ->
  moment = require 'moment'

.factory 'd3', ->
  d3 = require 'd3'
