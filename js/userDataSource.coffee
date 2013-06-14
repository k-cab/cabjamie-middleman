# TODO factor out the parse impl
# TODO resolve API inconsistency
# TODO factor out attr <-> prop.

Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

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
        page = new @Page result
        @attrsToProps page, 'url', 'stickers', 'note'

        resultHandler [ page ]

    fetchStickers: (page, resultHandler) ->
      evernote.fetchStickers_evernote page, resultHandler

    fetchItems: (params, resultHandler) ->
      @fetchItems_parse params, resultHandler

    persist: (type, modelObj, resultHandler) ->
      evernote.persist_evernote type, modelObj, resultHandler


    #=

    fetchPage_stub: (params, resultHandler) ->
      result = new @Page()
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


    #=     
     
    fetchPage_parse: (params, resultHandler) ->
      url = params.url

      query = new Parse.Query(@Page) 
      query.equalTo('url', url)
      # query.include('stickers')
      
      that = this
      query.find
        success: (results) ->
          $log.info { url, results }

          if results.length > 0
            result = results[0]
          else
            result = new that.Page()
            result.url = url
            result.stickers = []

          results.push result


          # HACK convert the attrs to properties.
          that.attrsToProps result, 'url', 'title'

          that.fetchStickers result, (stickers) ->
            resultHandler results      
                  
        error: (error) ->
          $log.info "Error: " + error.code + " " + error.message
          # deferred.notify error
          resultHandler error

    fetchStickers_parse: (page, resultHandler) ->
      if page == null
        query = new Parse.Query(@Sticker)
      else
        # in order to prevent saving a possibly unnecessary page, we shortcut to the result handler if page is new.
        if page.isNew()
          resultHandler []
          return

        query = page.relation('stickers').query()

      that = this
      query.find

        success: (stickers) ->
          $log.info "fetched #{stickers.length} stickers for #{page}"
          stickers.forEach (sticker) -> 
            that.attrsToProps sticker, 'name'

          page.stickers = stickers if page

          resultHandler stickers

        error: (error) ->
          $log.error error

    fetchItems_parse: (params, resultHandler) ->
    
      # TODO address abstraction gap between items and pages.
      query = new Parse.Query(@Page) 
      query.equalTo('stickers', params[0])

      that = this
      query.find
        success: (results) ->
          $log.info { params, results }

          # HACK convert the attrs to properties.
          results.forEach (result) -> 
            that.attrsToProps result, 'url'
          
          resultHandler results

        error: (error) ->
          $log.info "Error: " + error.code + " " + error.message
          # deferred.notify error
          resultHandler error

          results.forEach (result) -> 
            that.attrsToProps result, 'name', 'url'
          

    persist_parse: (type, modelObj, resultHandler) ->
      that = this
      switch type
        when 'page'
          properties = [ 'url' ]  # only non-collection properties

          # set up the relation for stickers
          $log.info { page: modelObj, stickers: modelObj.stickers }
          stickersRelation = modelObj.relation('stickers')
          stickersRelation.add modelObj.stickers
          # FIXME remove the unstickered stickers from the relation.

        when 'sticker'
          properties = [ 'name' ]

          # create the obj
          unless modelObj.className == 'Sticker'
            theObj = new @Sticker()
            theObj.name = modelObj.name
            modelObj = theObj

      # REFACTOR
      properties.forEach (p) =>
        modelObj.set(p, modelObj[p])

      modelObj.save null,
        success: (theObj) ->
          $log.info "save successful"

          resultHandler theObj if resultHandler

        error: (theObj) ->
          $log.error theObj

    ##

         
    ##

    attrsToProps: (obj, attrs...) ->
      attrs.forEach (attr) ->
        val = obj.get attr
        obj[attr] = val if val
          

    ## REFACTOR

    Page: Parse.Object.extend 'Page',

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

    Sticker: Parse.Object.extend('Sticker')


