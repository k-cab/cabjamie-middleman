# TODO resolve API inconsistency


class Sticker
  constructor: (data) ->
    Object.keys(data).map (key) =>
      this[key] = data[key]  

  name: 'unnamed sticker'


class Page
  constructor: (data) ->
    Object.keys(data).map (key)=>
      this[key] = data[key]  
  
  url: 'http://stub-url'

  addSticker: (sticker) ->

    this.stickers = [] unless this.stickers
    this.stickers.push sticker unless _.include this.stickers, sticker

    # $log.info   # TODO factor out as angular module
    console.log { this:this, stickers: this.stickers }

  removeSticker: (sticker) ->
    console.log "TODO remove sticker from #{this.url}"
    this.stickers = this.stickers.filter( (e) -> e.name != sticker.name )
  
  hasSticker: (sticker) ->
    if _.include this.stickers?.map((e) -> e.name), sticker.name
      true
    else
      false



@appModule.factory 'userDataSource', ($log, $http, evernote) ->
  obj = 
    init: ->
      evernote.init()

    # FIXME redundant
    fetch: (dataType, params, resultHandler) ->
      switch dataType
        when 'stickers'
          @fetchStickers null, resultHandler
        when 'items'
          @fetchItems params, resultHandler
        when 'page'
          @fetchPage params, resultHandler
        else
          throw "unknown data type #{dataType}"


    # FIXME resultHandler interface should deal with single page.
    fetchPage: (params, resultHandler) ->
      evernote.fetchPage_evernote params, (result) =>
        page = new Page result

        resultHandler [ page ]

    fetchStickers: (page, resultHandler) ->
      evernote.fetchStickers_evernote page, resultHandler

    fetchItems: (params, resultHandler) ->
      @fetchItems_parse params, resultHandler

    persist: (type, modelObj, resultHandler) ->
      evernote.persist_evernote type, modelObj, resultHandler


    #=

    fetchPage_stub: (params, resultHandler) ->
      result = new Page()
      result.url = params.url
      result.stickers = []

      resultHandler [ result ]


    fetchStickers_stub: (page, resultHandler) ->
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

