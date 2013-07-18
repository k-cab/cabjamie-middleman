app = @appModule

@appModule.factory 'evernoteSvc', ($log, $http) ->
  
  obj = 

    #= userDataSource interface realisation

    fetchStickers: (page) ->
      if page == null
        Q.fcall ->
          obj.listTags()
        .then (tags)->
          obj.ifError tags, Q
          
          $log.info tags
          matchingTags = tags.filter (tag) -> tag.name.match app.userPrefs.sticker_prefix_pattern

          stickers = matchingTags.map (tag) ->
            sticker = new Sticker
              implObj: tag
              id: tag.guid
              name: tag.name

          return stickers

      else
        throw "don't call me for page stickers."


    fetchPage: (params) ->

      Q.fcall ->
        obj.fetchNote
          url: params.url
      .then (result)->
        pageData = 
          url: params.url
          title: params.title
          stickers: result?.tags?.map (tag) ->
            name: tag.name
            guid: tag.guid
          note: result

        # if no previous note for this url
        pageData.stickers ||= []

        page = new Page pageData
        return page

    createSticker: (newSticker) ->
      obj.persist 'sticker', newSticker

    updateSticker: (newSticker) ->
      obj.persist 'sticker', newSticker

    deleteSticker: (sticker) ->
      sticker.name = "archived - " + sticker.name
      obj.persist 'sticker', sticker


    persist: (type, modelObj) ->
      # FIXME update the note after creation on multiple stickerings.

      switch type
        when 'page'

          htmlSafeUrl = _.escape modelObj.url

          return obj.saveNote
            guid: modelObj.note?.guid
            title: modelObj.title
            content: "On #{new Date()}, you stickered the page <a href='#{encodeURI(htmlSafeUrl)}'>'#{modelObj.title}'</a>."
            tags: modelObj.stickers.concat { name: 'TagYeti' }
            thumbnail: modelObj.thumbnailUrl
            url: modelObj.url

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
          if modelObj.id
            # update
            modelObj.implObj.name = modelObj.name
            obj.updateTag( modelObj.implObj)
          else
            obj.createTag( modelObj)
            .then (tag) ->
              new Sticker
                id: tag.guid
                name: tag.name
                implObj: tag
            
            
          

      # # post note
      # $http.post(url, data)
      #   .success (data, status, headers, config) -> 
      #     $log.info data
      #     resultHandler modelObj

      #   .error (data, status, headers, config) ->
      #     throw { data, status, headers, config }



    #= Evernote service abstraction

    options:
      consumerKey: "sohocoke"
      consumerSecret: "80af1fd7b40f65d0"
      evernoteHostName: "https://www.evernote.com"


    init: ->
      obj.authToken = localStorage.getItem 'evernote_authToken'
      obj.noteStoreURL = localStorage.getItem 'evernote_noteStoreURL'

      unless obj.authToken and obj.noteStoreURL and obj.authToken != typeof undefined
        throw 
          msg: "couldn't initialise service access from localStorage" 
          errorType: "authentication"

      noteStoreTransport = new Thrift.BinaryHttpTransport(obj.noteStoreURL)
      noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
      obj.noteStore = new NoteStoreClient(noteStoreProtocol)

    ##

    listTags: ->
      deferred = Q.defer()

      obj.noteStore.listTags obj.authToken, (results)->
        obj.ifError results, deferred

        deferred.resolve results
    
      deferred.promise

    createTag: (tagData) ->
      deferred = Q.defer()

      tag = new Tag()
      tag.name = tagData.name
      obj.noteStore.createTag obj.authToken, tag, (result) ->
        obj.ifError result, deferred

        deferred.resolve result
    
      deferred.promise

    updateTag: (tag) ->
      deferred = Q.defer()

      obj.noteStore.updateTag obj.authToken, tag, (err, result) ->
        obj.ifError err, deferred

        deferred.resolve result

      deferred.promise
        
    deleteTag: (tag) ->
      deferred = Q.defer()

      obj.noteStore.updateTag obj.authToken, tag, (err, result) ->
        obj.ifError err, deferred

        deferred.resolve result

      deferred.promise


    fetchNote: (args) ->
      deferred = Q.defer()

      pageSize = 10;
       
      filter = new NoteFilter()
      filter.order = NoteSortOrder.UPDATED
      filter.words = "sourceURL:#{args.url}"
      
      spec = new NotesMetadataResultSpec()
      spec.includeTitle = true
      spec.includeTagGuids = true

      # sourceApplication TODO

      obj.noteStore.findNotesMetadata obj.authToken, filter, 0, pageSize, spec, (notesMetadata) =>
        obj.ifError notesMetadata, deferred

        $log.info { msg: "fetched notes", filter, spec, notesMetadata }
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
          # obj.noteStore.getNote obj.authToken, guid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData, (note) ->
          #   args.callback note

          fetchTags = noteMd.tagGuids?.map (tagGuid) =>
            d2 = Q.defer()
            obj.noteStore.getTag obj.authToken, tagGuid, (tag) ->
              obj.ifError tag, d2.reject

              d2.resolve tag

            d2.promise
          
          note = 
            guid: noteMd.guid
            url: args.url
            tags: []
                     
          if fetchTags
            Q.all(fetchTags)
            .then (tags)->
              note.tags = tags

              deferred.resolve note

          else
            deferred.resolve note
        else
          $log.info "no note matching #{args.url}"
          deferred.resolve null          
    
      deferred.promise


    saveNote: (args) ->
      deferred = Q.defer()

      note = new Note()
      note.title = args.title
      note.tagNames = args.tags.map (tag) -> 
        throw "invalid tag: #{tag}" unless tag.name
        tag.name

      attrs = new NoteAttributes()
      attrs.sourceURL = args.url
      note.attributes = attrs

      thumbnailDataB64 = _(args.thumbnail.split(',')).last()
      thumbnailData = atob thumbnailDataB64
      ab = new ArrayBuffer(thumbnailData.length)
      ia = new Uint8Array(ab)
      for e, i in thumbnailData
        ia[i] = thumbnailData.charCodeAt(i)
      thumbnailData = ia

      thumbnailMd5Hex = faultylabs.MD5 thumbnailData
      
      data = new Data()
      data.size = thumbnailData.length
      data.body = thumbnailData
      data.bodyHash = thumbnailMd5Hex

      resource = new Resource()
      resource.mime = 'image/jpeg'
      resource.data = data

      note.resources = [ resource ]

      note.content = """
        <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
        <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;">
          <div>#{args.content}</div>
          <en-media type="image/jpeg" hash="#{thumbnailMd5Hex}" width="100%"/>
        </en-note>
        """

      if args.guid
        # update the note.

        note.guid = args.guid
        obj.noteStore.updateNote obj.authToken, note, (callback) ->
          obj.ifError callback, deferred

          $log.info { msg: 'note updated', callback }

          deferred.resolve note
      else
        obj.noteStore.createNote obj.authToken, note, (callback) ->
          obj.ifError callback, deferred

          $log.info { msg: 'note saved', callback }
          note.guid = callback.guid

          deferred.resolve note

      deferred.promise


    ## helpers

    ifError: (result, deferred) ->
      if result.parameter == 'authenticationToken'
        result.errorType = 'authentication'

        deferred.reject result

      else
        deferred.reject result if result.type == "error" or result.name?.match /Exception/



  obj
