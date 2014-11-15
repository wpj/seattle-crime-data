describe 'services -', ->
  
  beforeEach module('app.services')

  describe 'dataCache', ->

    beforeEach inject '_dataCache_', ->
      @dataCache = _dataCache_

      describe 'setter method', ->
        beforeEach ->
          @dataCache.set [{
            "cad_event_number" : "12000277221",
            "cad_cdw_id" : "880382",
            "zone_beat" : "N3",
            "initial_type_description" : "FOLLOW UP",
            "district_sector" : "N",
            "initial_type_subgroup" : "MISCELLANEOUS",
            "incident_location" : {
              "needs_recoding" : false,
              "longitude" : "-122.33452433",
              "latitude" : "47.702331628"
            },
            "hundred_block_location" : "100XX BLOCK OF COLLEGE WAY N",
            "general_offense_number" : "2012277221",
            "longitude" : "-122.334524330",
            "latitude" : "47.702331628",
            "at_scene_time" : "2012-08-20T11:37:00",
            "initial_type_group" : "MISCELLANEOUS",
            "census_tract" : "1300.1009"
          }]

        it 'should set the cache', ->
          @dataCache.get().length.should.equal(1)

  describe 'Socrata', ->

    beforeEach inject (_$httpBackend_, _Socrata_) ->
      @$httpBackend = _$httpBackend_
      @Socrata      = _Socrata_

    describe 'requesting crash data', ->

      beforeEach ->
        @$httpBackend.expectGET('http://data.seattle.gov/resource/3k2p-39jp.json')
        .respond 200,
          [
            {
              "cad_event_number" : "12000277221",
              "cad_cdw_id" : "880382",
              "zone_beat" : "N3",
              "initial_type_description" : "FOLLOW UP",
              "district_sector" : "N",
              "initial_type_subgroup" : "MISCELLANEOUS",
              "incident_location" : {
                "needs_recoding" : false,
                "longitude" : "-122.33452433",
                "latitude" : "47.702331628"
              },
              "hundred_block_location" : "100XX BLOCK OF COLLEGE WAY N",
              "general_offense_number" : "2012277221",
              "longitude" : "-122.334524330",
              "latitude" : "47.702331628",
              "at_scene_time" : "2012-08-20T11:37:00",
              "initial_type_group" : "MISCELLANEOUS",
              "census_tract" : "1300.1009"
            }
          ]

        @Socrata.getData()
          .then (resp) => @response = resp
        @$httpBackend.flush()

      it 'should send an HTTP GET request', ->
        @$httpBackend.verifyNoOutstandingExpectation()
        @$httpBackend.verifyNoOutstandingRequest()
