# TODO resolve API inconsistency


@appModule.factory 'userDataSource', ($log, $http, evernote, stubDataSvc) ->
  obj = 
    init: ->
      evernote.init()


    # FIXME resultHandler interface should deal with single page.
    fetchPage: (pageSpec, resultHandler) ->
      stubDataSvc.fetchPage pageSpec, (result) =>
        page = new Page result

        resultHandler [ page ]

        # TODO err


    fetchStickers: (page, resultHandler) ->
      stubDataSvc.fetchStickers page, resultHandler

    fetchItems: (params, resultHandler) ->
      stubDataSvc.fetchItems params, resultHandler


    persist: (type, modelObj, resultHandler) ->
      stubDataSvc.persist type, modelObj, resultHandler

