that = this

@appModule.factory 'stubDataSvc', ($log, $http) ->
  
  obj = 
    #= userDataSource interface realisation
    
    init: ->
      
    fetchPage: (params) ->
      new RSVP.Promise (resolve, reject) ->

        result = new that.Page()
        result.url = params.url
        result.stickers = [
          {
            name: "stub-sticker-3"
          }
        ]

        resolve result


    fetchStickers: (page, resultHandler) ->
      results = [
        {
            name: "stub-sticker-1",
        },
        {
            name: "stub-sticker-2",
        },
        {
            name: "stub-sticker-3"
        },
      ]

      resultHandler results

    fetchItems: (params, resultHandler) ->
      new RSVP.Promise (resolve, reject) ->
        $log.error "stub fetchItems called"
        resolve null

    persist: (type, modelObj, resultHandler) ->
      new RSVP.Promise (resolve, reject) ->
        $log.error "stub persist called"
        resolve null
  obj
