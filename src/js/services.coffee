module.exports = angular.module('app.services', [])

.factory 'Socrata', ['$http', 'moment', 'dataCache', 'mapStats', ($http, moment, dataCache, mapStats) ->
  stadiumCoords =
    lat: 47.595312
    lng: -122.331606
    
  mileInMeters = 1609

  oneMonthAgo = moment().subtract(1, 'month').toISOString()

  query =
    $limit: 5000
    $where: "at_scene_time>'#{oneMonthAgo}' AND within_circle(incident_location,#{stadiumCoords.lat},#{stadiumCoords.lng},#{mileInMeters})"

  getData: ->
    console.log 'getting data'
    $http.get "http://data.seattle.gov/resource/3k2p-39jp.json",
      params: query
    .then (response) ->
      dataCache.set response.data
      crimes = for record in response.data
        do (record) ->
          if coords = record.incident_location
            mapStats.compareDistance [parseFloat(coords.latitude), parseFloat(coords.longitude)]
            mapStats.extractCrimeTypes record.event_clearance_group
            record
]

.factory 'dataCache', ->
  cache = null
  isCached = false

  isCached: -> isCached
  get: -> cache
  set: (newCache) ->
    isCached = true
    cache = newCache

.factory 'mapStats', ->
  within =
    "1/4": 0
    "1/2": 0
    "3/4": 0
    "1": 0

  crimeTypes =
    "NOT REPORTED": 0

  stadiumCoords = L.latLng [47.595312, -122.331606]

  compareDistance = (coords) ->
    distance = stadiumCoords.distanceTo(coords)

    if distance < 402
      within["1/4"]++
    else if distance < 804
      within["1/2"]++
    else if distance < 1207
      within["3/4"]++
    else
      within["1"]++

  extractCrimeTypes = (crime) ->
    if crime
      if crime of crimeTypes
        crimeTypes[crime]++
      else
        crimeTypes[crime] = 1
    else
      crimeTypes["NOT REPORTED"]++

  compareDistance: compareDistance
  extractCrimeTypes: extractCrimeTypes
  show: ->
    distances: within
    crimeTypes: crimeTypes

.factory 'moment', ->
  moment = require 'moment'

.factory 'd3', ->
  d3 = require 'd3'
