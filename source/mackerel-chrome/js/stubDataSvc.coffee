that = this

@appModule.factory 'stubDataSvc', ($log, $http, $resource) ->
  
  obj = 
    #= userDataSource interface realisation
    
    init: ->
      
    fetchPage: (params) ->
      deferred = Q.defer()

      results = $resource('http://localhost\\:8081/mackerel/page').get params, ->
        deferred.resolve results

      deferred.promise


    fetchStickers: (page) ->
      deferred = Q.defer()

      results = $resource('http://localhost\\:8081/mackerel/tags').query ->
        results = results.map (e) ->
          new that.Sticker e

        deferred.resolve results

      deferred.promise

    updateSticker: (sticker) ->
      Q.fcall ->
        $log.error "stub updateSticker called"
        return null
    

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
