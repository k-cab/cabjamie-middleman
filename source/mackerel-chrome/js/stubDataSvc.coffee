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


    fetchStickers: (page) ->
      deferred = Q.defer()

      results = $resource('http://localhost\\:8081/mackerel/stickers').query ->
        results = results.map (e) ->
          new that.Sticker e

        deferred.resolve results

      deferred.promise


    updateSticker: (sticker) ->
      Q.fcall ->
        $log.error "stub updateSticker called"
        return null

    savePage: (page)->
      deferred = Q.defer()

      $resource('http://localhost\\:8081/mackerel/page').save page, ->
        # TODO fill in the id

        deferred.resolve page

        # TODO error

      deferred.promise



    persist: (type, modelObj, resultHandler) ->
      Q.fcall ->
        $log.error "stub persist called"
        return null


    # unmaintained

    fetchItems: (params, resultHandler) ->
      Q.fcall ->
        $log.error "stub fetchItems called"
        return null


  return obj
