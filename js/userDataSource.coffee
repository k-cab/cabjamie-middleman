# TODO factor out into multiple implementations of the interface.
# TODO resolve API inconsistency
# TODO factor out attr <-> prop.

Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

@appModule.factory 'userDataSource', ($log, $http) ->
  obj = 
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
      @fetchPage_evernote params, resultHandler

    fetchStickers: (page, resultHandler) ->
      @fetchStickers_evernote page, resultHandler

    fetchItems: (params, resultHandler) ->
      @fetchItems_parse params, resultHandler

    persist: (type, modelObj, resultHandler) ->
      @persist_evernote type, modelObj, resultHandler

          
    fetchPage_parse: (params, resultHandler) ->
      url = params[0]

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

          results.push result


          # HACK convert the attrs to properties.
          that.attrsToProps result, 'url'

          that.fetchStickers result, (stickers) ->
            resultHandler results      
                  
        error: (error) ->
          $log.info "Error: " + error.code + " " + error.message
          # deferred.notify error
          resultHandler error

    fetchPage_evernote: (params, resultHandler) ->
      that = this
      @evernote.fetchNote
        url: params[0]
        callback: (result)->
          page = new that.Page()
          page.url = params[0]

          unless result
            # no previous note for this url
            page.stickers = []            
          else
            page.note = result
            page.stickers = result.tags.map (tag) ->
              name: tag.name
              guid: tag.guid

          resultHandler [ page ]            

    fetchPage_stub: (params, resultHandler) ->
      result = new @Page()
      result.url = params[0]
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

    fetchStickers_evernote: (page, resultHandler) ->
      if page == null
        @evernote.listTags (tags) ->
          $log.info tags
          stickers = tags.filter (tag) -> tag.name.match /^##/
          resultHandler stickers

      else
        # throw "don't call me for page stickers."


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

    persist_evernote: (type, modelObj, resultHandler) ->
      # FIXME update the note after creation on multiple stickerings.

      switch type
        when 'page'

          @evernote.saveNote
            guid: modelObj.guid
            title: 'stub note'
            content: 'stub note content'
            tags: modelObj.stickers

            url: modelObj.url
            callback: resultHandler

          # url = "http://localhost:8081/notes"
          # data = 
          #   title: modelObj.url
          #   content: """
          #     <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          #     <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;"><div>useful content from page to go here...</div>
          #     </en-note>
          #     """
          #   tagNames: modelObj.stickers.map (sticker) -> sticker.name          

        when 'sticker'
          throw "unimplemented"

      # # post note
      # $http.post(url, data)
      #   .success (data, status, headers, config) -> 
      #     $log.info data
      #     resultHandler modelObj

      #   .error (data, status, headers, config) ->
      #     throw { data, status, headers, config }


    ##

    evernote:
      init: ->
        @authToken = 'S=s1:U=6bbf6:E=1467335cb26:C=13f1b849f29:P=1cd:A=en-devtoken:V=2:H=af79274188c8caa763811073776c32d7'
        noteStoreURL = 'https://sandbox.evernote.com/shard/s1/notestore'
        noteStoreTransport = new Thrift.BinaryHttpTransport(noteStoreURL)
        noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
        @noteStore = new NoteStoreClient(noteStoreProtocol)

      listTags: (callback) ->
        @noteStore.listTags @authToken, callback
      
      # fetchTags: (guids, callback) ->
        
      #   callback tags
      
      fetchNote: (args) ->
        pageSize = 10;
         
        filter = new NoteFilter();
        filter.order = NoteSortOrder.UPDATED
        filter.words = "sourceURL:#{args.url}"
        
        spec = new NotesMetadataResultSpec()
        spec.includeTitle = true
        spec.includeTagGuids = true

        # sourceApplication TODO

        @noteStore.findNotesMetadata @authToken, filter, 0, pageSize, spec, (notesMetadata) =>
          if notesMetadata.notes.length > 1
            $log.warn
              msg: "multiple results for #{args.url}"
              notesMetadata

          noteMd = notesMetadata.notes[0]
          if noteMd
            # guid = noteMd.guid
            # withContent = false
            # withResourcesData = false
            # withResourcesRecognition = false
            # withResourcesAlternateData = false
            # @noteStore.getNote @authToken, guid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData, (note) ->
            #   args.callback note

            fetchTags = noteMd.tagGuids.map (tagGuid) =>
              new RSVP.Promise (resolve, reject) =>
                @noteStore.getTag @authToken, tagGuid, (tag) ->
                  resolve tag
              
            RSVP.all(fetchTags)
            .then (tags)->
              note = 
                url: args.url
                tags: tags

              args.callback note
          else
            args.callback null          
      
      saveNote: (args) ->
        note = new Note()
        note.title = args.title
        note.content = """
          <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
          <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;"><div>#{args.content}</div>
          </en-note>
          """
        note.tagNames = args.tags.map (tag) -> tag.name
        attrs = new NoteAttributes()
        attrs.sourceURL = args.url
        note.attributes = attrs

        @noteStore.createNote @authToken, note, (callback) ->
          $log.info { msg: 'note saved', callback }
          note.guid = callback.guid

          args.callback note if args.callback
        
    ##

    attrsToProps: (obj, attrs...) ->
      attrs.forEach (attr) ->
        val = obj.get attr
        obj[attr] = val if val
          

    ## REFACTOR

    Page: Parse.Object.extend 'Page',

      url: 'stub-url'

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


  ##

  obj.evernote.init()
  obj
