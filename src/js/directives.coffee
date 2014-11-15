module.exports = angular.module('app.directives', [])

module.exports = angular.module('app.directives', [])

.directive 'crimeMap', ['$modal', ($modal) ->
  restrict: 'E'
  template: '<div class="map-container"></div>'
  # replace: true
  scope:
    center: '='
    options: '='
    crimeData: '='
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

    setLayers = (records) ->
      for record in records
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

    ###
    event listeners, $watches, view updates
    ###

    scope.$watch 'center', ->
      map.setView scope.center

    scope.$watch 'crimeData', ->
      setLayers(scope.crimeData) if scope.crimeData

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
]

.directive 'pieChart', ['d3', 'dataCache', (d3, dataCache) ->
  restrict: 'E'
  template: '<div id="pie-chart" class="chart-container"></div>'
  scope:
    data: '='
  link: (scope, elem, attrs) ->
    config =
      w: 500
      h: 500

    pie = d3.layout.pie().value (d) -> d.value

    outerRadius = config.w / 2
    innerRadius = 150

    arc = d3.svg.arc()
          .innerRadius(innerRadius)
          .outerRadius(outerRadius)

    color = d3.scale.category10()

    # 
    # draw svg on DOM
    # 
    svg = d3.select '#pie-chart'
          .append 'svg'
          .attr 'width', config.w
          .attr 'height', config.h
          .attr 'viewBox', '0,0,500,500'
          .attr 'preserveAspectRatio', 'xMinYMin meet'


    # 
    # draw pie chart wedges
    # 
    drawWedges = (data) ->
      dataset = d3.entries data
      dataLength = dataCache.get().length
      formatPercent = d3.format '%'
      arcs = svg.selectAll 'g.arc'
              .data pie(dataset)
              .enter()
              .append 'g'
              .attr 'class', 'arc'
              .attr 'transform', "translate(#{outerRadius}, #{outerRadius})"

      centerGroup = svg.append 'g'
        .attr 'transform', "translate(#{config.w/2},#{config.h/2})"

      centerLabel = centerGroup.append 'svg:text'
        .attr 'text-anchor', 'middle'
        .attr 'class', 'center-label'

      arcs.append 'path'
        .attr 'fill', (d, i) -> color(i)
        .attr 'd', arc

      arcs.append 'svg:text'
        .attr 'transform', (d) -> "translate(#{arc.centroid(d)})"
        .attr 'text-anchor', 'middle'
        .text (d) -> "#{d.data.key} mile"

      arcs.on 'mouseover', (d) ->
        formattedPercent = formatPercent(d.data.value/dataLength)
        centerLabel.text "#{formattedPercent}  (#{d.data.value} total)"

    scope.$watch 'data', ->
      drawWedges(scope.data) if scope.data?["1/4"] or scope.data?["1/2"]
]

.directive 'barGraph', ['d3', (d3) ->
  restrict: 'E'
  template: '<div id="bar-graph" class="chart-container"></div>'
  scope:
    data: '='
  link: (scope, elem, attrs) ->
    
    margin = {top: 20, right: 50, bottom: 170, left: 40}
    width = 960 - margin.left - margin.right
    height = 700 - margin.top - margin.bottom

    x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1)

    y = d3.scale.linear()
        .range([height, 0])

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")

    svg = d3.select "#bar-graph"
      .append "svg"
        .attr "width", width + margin.left + margin.right
        .attr "height", height + margin.top + margin.bottom
        .attr 'viewBox', "0,0,960,700"
        .attr 'preserveAspectRatio', 'xMinYMin meet'
      .append "g"
        .attr "transform", "translate(#{margin.left},#{margin.top})"

    drawChart = ->
      data = d3.entries scope.data
      x.domain data.map (d) -> d.key
      y.domain [0, d3.max data, (d) -> d.value]

      svg.append "g"
          .attr "class", "x axis"
          .attr "transform", "translate(0,#{height})"
          .call xAxis
          .selectAll "text"
            .attr "y", 5
            .attr "x", 9
            .attr "dy", ".35em"
            .attr "transform", "rotate(60)"
            .style "text-anchor", "start"

      svg.append "g"
          .attr "class", "y axis"
          .call yAxis
        .append "text"
          .attr "transform", "rotate(-90)"
          .attr "y", 6
          .attr "dy", ".71em"
          .style "text-anchor", "end"
          .text "Crime Frequency"

      bars = svg.selectAll ".bar"
          .data data
        .enter().append "rect"
          .attr "class", "bar"
          .attr "x", (d) -> x(d.key)
          .attr "width", x.rangeBand()
          .attr "y", (d) -> y(d.value)
          .attr "height", (d) -> height - y(d.value)

      bars.on 'mouseover', (d) ->
        xPosition = parseFloat(d3.select(this).attr('x')) + x.rangeBand() / 2
        yPosition = parseFloat(d3.select(this).attr("y")) - 3
        svg.append 'text'
        .attr 'x', xPosition
        .attr 'y', yPosition
        .attr 'text-anchor', 'middle'
        .attr 'id', 'tool-tip'
        .attr 'fill', 'black'
        .text d.value

      bars.on 'mouseout', ->
        d3.select("#tool-tip").remove()

    scope.$watch 'data', ->
      drawChart() if scope.data

]
