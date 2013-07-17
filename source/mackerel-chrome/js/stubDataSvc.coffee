that = this

@appModule.factory 'stubDataSvc', ($log, $http, $resource) ->
  
  obj = 
    #= userDataSource interface realisation
    
    init: ->
      
    fetchPage: (params) ->
      deferred = Q.defer()

      result = $resource('http://localhost\\:8081/mackerel/page').get params, ->
        page = new Page result
        deferred.resolve page

      deferred.promise


    savePage: (page)->
      deferred = Q.defer()

      $resource('http://localhost\\:8081/mackerel/page').save pageData, ->
        # TODO fill in the id

        deferred.resolve page

        # TODO error

      deferred.promise



    fetchStickers: (page) ->
      deferred = Q.defer()

      results = $resource('http://localhost\\:8081/mackerel/stickers').query ->
        results = results.map (e) ->
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

      $resource('http://localhost\\:8081/mackerel/stickers').save {}, sticker, (stickerData)->

        deferred.resolve sticker

        # TODO error

      deferred.promise

    # TODO resolve api to 'saveSticker'.


    deleteSticker: (sticker) ->
      sticker.name = "archived - " + sticker.name
      Q.fcall ->
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
