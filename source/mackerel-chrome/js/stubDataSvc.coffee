that = this

@appModule.config (RestangularProvider)-> 
    RestangularProvider.setBaseUrl("http://localhost:8081/mackerel")
    RestangularProvider.setFullRequestInterceptor (el, op, what, url, headers, params)->
      headers['x-username'] = 'sohocoke'
      # FIXME read username from localStorage
      headers: headers
      params: params
      element: el
  

@appModule.factory 'stubDataSvc', ($log, $http, $resource, Restangular) ->
  
  obj = 
    #= userDataSource interface realisation
    
    init: ->
      
    fetchPage: (params) ->
      deferred = Q.defer()

      Restangular.one('page').get(params)
      .then (pageData)->
        # FIXME pageData has a lot of properties from restangular.

        page = new Page pageData
        deferred.resolve page

      deferred.promise


    savePage: (page)->
      deferred = Q.defer()

      page.post()
      .then (pageData)->
        # TODO fill in the id

        deferred.resolve page

        # TODO error

      deferred.promise



    fetchStickers: (page) ->
      deferred = Q.defer()

      Restangular.all('stickers').getList()
      .then (stickersData) ->
        results = stickersData.map (e) ->
          new that.Sticker e

        deferred.resolve results

      deferred.promise


    createSticker: (sticker) ->
      deferred = Q.defer()

      $resource('http://localhost\\:8081/mackerel/stickers').save sticker, (stickerData)->
        sticker.id = stickerData.guid

        deferred.resolve sticker

        # TODO error

      deferred.promise      
    

    updateSticker: (sticker) ->
      deferred = Q.defer()

      $resource('http://localhost\\:8081/mackerel/stickers').save sticker, (stickerData)->

        deferred.resolve sticker

        # TODO error

      deferred.promise

    # TODO resolve api to 'saveSticker'.


    deleteSticker: (sticker) ->
      sticker.name = "archived - " + sticker.name
      obj.updateSticker sticker


    persist: (type, modelObj, resultHandler) ->
      Q.fcall ->
        $log.error "stub persist called"
        return null



    # tactically unmaintained

    fetchItems: (params, resultHandler) ->
      Q.fcall ->
        $log.error "stub fetchItems called"
        return null


  return obj
