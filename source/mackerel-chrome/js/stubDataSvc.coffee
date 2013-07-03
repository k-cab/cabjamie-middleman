that = this

@appModule.factory 'stubDataSvc', ($log, $http) ->
  
  obj = 
    #= userDataSource interface realisation
    
    init: ->
      
    fetchPage: (params) ->
      Q.fcall ->

        result = new that.Page()
        result.url = params.url
        result.stickers = [
          {
            name: "stub-sticker-3"
          }
        ]

        return result


    fetchStickers: (page) ->
      Q.fcall ->
        results = [
          {
            id: 1
            name: "stub-sticker-1",
          },
          {
            id: 2
            name: "stub-sticker-2",
          },
          {
            id: 3
            name: "stub-sticker-3"
          },
        ]

        results = results.map (e) ->
          new that.Sticker e

        return results

    fetchItems: (params, resultHandler) ->
      Q.fcall ->
        $log.error "stub fetchItems called"
        return null


    updateSticker: (sticker) ->
      Q.fcall ->
        $log.error "stub updateSticker called"
        return null
    

    persist: (type, modelObj, resultHandler) ->
      Q.fcall ->
        $log.error "stub persist called"
        return null

  return obj