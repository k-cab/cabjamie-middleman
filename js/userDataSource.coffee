# TODO resolve API inconsistency


@appModule.factory 'userDataSource', ($log, $http, evernote, stubDataSvc) ->
  
  impl = stubDataSvc
  impl = evernote

  obj = 
    init: ->
      evernote.init()


    # FIXME resultHandler interface should deal with single page.
    fetchPage: (pageSpec) ->
      new RSVP.Promise (resolve, reject) ->

        impl.fetchPage( pageSpec)
        .then (result) =>
          page = new Page result
          resolve page

    fetchStickers: (page, resultHandler) ->
      impl.fetchStickers page, resultHandler

    fetchItems: (params, resultHandler) ->
      impl.fetchItems params, resultHandler


    persist: (type, modelObj, resultHandler) ->
      impl.persist type, modelObj, resultHandler

