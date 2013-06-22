# TODO resolve API inconsistency

# FIXME this class looks silly. move model creation to implementations?
that = this
@appModule.factory 'userDataSource', (
  $log, $http
  ) ->

  impl: null
  
  init: ->
    @impl.init()


  fetchPage: (pageSpec) ->
    new RSVP.Promise (resolve, reject) =>

      @impl.fetchPage( pageSpec)
      .then (result) =>
        page = new Page result
        resolve page

  fetchStickers: (page, resultHandler) ->
    @impl.fetchStickers page, (stickerData) ->
      stickers = stickerData.map (e) ->
        new Sticker e
    
      resultHandler stickers

  fetchItems: (params, resultHandler) ->
    @impl.fetchItems params, resultHandler


  persist: (type, modelObj, resultHandler) ->
    @impl.persist type, modelObj, resultHandler

