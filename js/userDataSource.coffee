Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

@appModule.factory 'userDataSource', ($log) ->

  fetch: (dataType, params, resultHandler) ->
    # just the sticker type for now.

    # this.fetch_stub dataType, resultHandler
    this.fetch_parse dataType, params, resultHandler


  fetch_stub: (dataType, resultHandler) ->
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

  fetch_parse: (dataType, params, resultHandler) ->
    that = this
    switch dataType
      when 'stickers'
        Sticker = Parse.Object.extend('Sticker')
        query = new Parse.Query(Sticker)

        preprocessResults = ->

      when 'items'
        # TODO address abstraction gap between items and pages.
        query = new Parse.Query(@Page) 
        query.equalTo('stickers', params[0])
        preprocessResults = (results) ->
          results.forEach (result) ->

            # this.fetchStickers result
                          
      when 'page'
        query = new Parse.Query(@Page) 
        query.equalTo('url', params[0])
        # query.include('stickers')
        
        preprocessResults = (results) ->
          if results.length > 0
            result = results[0]

            # debugger

          else
            result = new that.Page()
            results.push result

      else
        throw "unknown data type #{dataType}"
   
    that = this
    query.find
      success: (results) ->
        $log.info "Successfully retrieved " + results.length + " entries."

        preprocessResults results

        # HACK convert the attrs to properties.
        results.forEach (result) -> 
          that.attrsToProps result, 'name', 'url'
        
        resultHandler results

      error: (error) ->
        $log.info "Error: " + error.code + " " + error.message
        # deferred.notify error
        resultHandler error

  fetchStickers: (page, resultHandler) ->  # stub impl
    return if page.isNew()

    that = this
    page.relation('stickers').query().find

      success: (stickers) ->
        $log.info "fetched #{stickers.length} stickers for #{page}"
        stickers.forEach (sticker) -> 
          that.attrsToProps sticker, 'name'

        page.stickers = stickers

        resultHandler stickers

      error: (error) ->
        $log.error error



  persist: (type, modelObj) ->
    @persist_parse type, modelObj

  persist_parse: (type, modelObj) ->
    that = this
    switch type
      when 'page'
        properties = [ 'url' ]  # only non-collection properties

        # set up the relation for stickers
        if modelObj.stickers
          $log.info { stickers: modelObj.stickers }
          stickersRelation = modelObj.relation('stickers')
          stickersRelation.add modelObj.stickers

      when 'sticker'
        properties = []

    # REFACTOR
    properties.forEach (p) =>
      modelObj.set(p, modelObj[p])

    modelObj.save null,
      success: (theObj) ->
        $log.info "save successful"
      error: (theObj) ->
        $log.info "save failed"


  attrsToProps: (obj, attrs...) ->
    attrs.forEach (attr) ->
      val = obj.get attr
      obj[attr] = val if val
        

  Page: Parse.Object.extend 'Page',

    url: 'stub-url'

    addSticker: (sticker) ->

      this.stickers = [] unless this.stickers
      this.stickers.push sticker unless _.include this.stickers, sticker

      # $log.info   # TODO factor out as angular module
      console.log
        obj: this
        msg: "stickers: #{this.stickers}"

    hasSticker: (stickerName) ->
      if _.include this.stickers?.map((e) -> e.name), stickerName
        true
      else
        false

