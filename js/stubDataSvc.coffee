that = this

@appModule.factory 'stubDataSvc', ($log, $http) ->
  
  obj = 
    #= userDataSource interface realisation
     
    fetchPage: (params, resultHandler) ->
      new RSVP.Promise (resolve, reject) ->

        result = new that.Page()
        result.url = params.url
        result.stickers = [
          {
            name: "stub-sticker-3"
          }
        ]

        resolve [ result ]


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
      $log.info "stub fetchItems called"

    persist: (type, modelObj, resultHandler) ->
      $log.info "stub persist called"

  obj
