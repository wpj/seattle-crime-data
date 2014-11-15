module.exports = angular.module('app.directives', [])

module.exports = angular.module('app.directives', [])

.directive 'collisionMap', ['Socrata', '$modal', 'mapStats', (Socrata, $modal, mapStats) ->
  restrict: 'E'
  template: '<div class="map-container"></div>'
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

    # base tile layer
    L.tileLayer 'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    .addTo(map)

    # heatmap layer
    heatLayer = L.heatLayer([],
      maxZoom: 15
      radius: 15
      blur: 25
    )

    ###
    marker layers
    ###

    clusterLayer = new L.MarkerClusterGroup(disableClusteringAtZoom: 15)
    markersLayer = L.layerGroup()

    setLayers = ->
      Socrata.getData()
        .then (response) ->
          records = response.data
          heatCoords = for record in records
            do (record) ->
              if coords = record.incident_location
                c = [parseFloat(coords.latitude), parseFloat(coords.longitude)]
                marker = L.marker(c)

                marker.addTo clusterLayer
                marker.addTo markersLayer
                heatLayer.addLatLng c

                marker.on 'click', (e) ->
                  $modal.open
                    templateUrl: 'data-modal.html'
                    controller: 'DataModalCtrl'
                    resolve:
                      dataPoint: -> record

                mapStats.compareDistance c
                mapStats.extractCrimeTypes record.event_clearance_group

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

    scope.$watch 'options.displayMode', (newVal, oldVal) ->
      if newVal is 'heat'
        map.removeLayer clusterLayer
        map.removeLayer markersLayer
        map.addLayer heatLayer
      else
        scope.options.disableClustering = false
        map.removeLayer heatLayer
        map.addLayer clusterLayer

    setLayers()
]

.directive 'pieChart', ['d3', (d3) ->
  restrict: 'E'
  template: '<div id="pie-chart" class="chart-container"></div>'
  scope:
    data: '='
  link: (scope, elem, attrs) ->
    config =
      w: 500
      h: 500

    pie = d3.layout.pie()

    outerRadius = config.w / 2
    innerRadius = 0

    arc = d3.svg.arc()
          .innerRadius(innerRadius)
          .outerRadius(outerRadius)

    color = d3.scale.category10()

    # 
    # draw svg on DOM
    # 
    dataset = d3.values scope.data

    svg = d3.select '#pie-chart'
          .append 'svg'
          .attr 'width', config.w
          .attr 'height', config.h
          .attr 'viewBox', '0,0,500,500'
          .attr 'preserveAspectRatio', 'xMinYMin meet'


    # 
    # draw pie chart wedges
    # 
    arcs = svg.selectAll 'g.arc'
            .data pie(dataset)
            .enter()
            .append 'g'
            .attr 'class', 'arc'
            .attr 'transform', "translate(#{outerRadius}, #{outerRadius})"

    arcs.append 'path'
      .attr 'fill', (d, i) ->
        console.log "#{i}:", d
        color(i)
      .attr 'd', arc

    arcs.append 'text'
      .attr 'transform', (d) -> "translate(#{arc.centroid(d)})"
      .attr 'text-anchor', 'middle'
      .text (d) -> d.value
]
