@appModule.factory 'evernoteSvc', ($log, $http) ->
  
  obj = 
    #= userDataSource interface realisation

    fetchStickers: (page, resultHandler) ->
      if page == null
        obj.listTags (tags) ->
          throw tags if tags.type == "error"
          
          $log.info tags
          stickers = tags.filter (tag) -> tag.name.match /^##/
          resultHandler stickers

      else
        throw "don't call me for page stickers."


    fetchPage: (params) ->

      new RSVP.Promise (resolve, reject) ->

        obj.fetchNote
          url: params.url
          callback: (result)->
            pageData = 
              url: params.url
              title: params.title
              stickers: result?.tags?.map (tag) ->
                name: tag.name
                guid: tag.guid
              note: result

            # if no previous note for this url
            pageData.stickers ||= []

            resolve pageData


    persist: (type, modelObj, resultHandler) ->
      # FIXME update the note after creation on multiple stickerings.

      switch type
        when 'page'

          htmlSafeUrl = _.escape modelObj.url

          return obj.saveNote
            guid: modelObj.note?.guid
            title: modelObj.title
            content: "On #{new Date()}, you stickered the page <a href='#{encodeURI(htmlSafeUrl)}'>'#{modelObj.title}'</a>."
            tags: modelObj.stickers.concat { name: 'Mackerel' }
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
          obj.createTag( '##' + modelObj.name )
          .then (tag) ->
            $log.info { msg: "created new tag", tag }
          
            resultHandler tag
          

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

      throw "couldn't intialise from localStorage" unless obj.authToken and obj.noteStoreURL

      noteStoreTransport = new Thrift.BinaryHttpTransport(obj.noteStoreURL)
      noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
      obj.noteStore = new NoteStoreClient(noteStoreProtocol)

    ##

    listTags: (callback) ->
      obj.noteStore.listTags obj.authToken, callback
    
    createTag: (name) ->
      new RSVP.Promise (resolve, reject) ->
        tag = new Tag()
        tag.name = name
        obj.noteStore.createTag obj.authToken, tag, (results) ->
          if results.type == 'error'
            reject results
          else
            resolve results
        
    
    fetchNote: (args) ->
      pageSize = 10;
       
      filter = new NoteFilter()
      filter.order = NoteSortOrder.UPDATED
      filter.words = "sourceURL:#{args.url}"
      
      spec = new NotesMetadataResultSpec()
      spec.includeTitle = true
      spec.includeTagGuids = true

      # sourceApplication TODO

      obj.noteStore.findNotesMetadata obj.authToken, filter, 0, pageSize, spec, (notesMetadata) =>
        throw notesMetadata if notesMetadata.type == "error"

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
            new RSVP.Promise (resolve, reject) =>
              obj.noteStore.getTag obj.authToken, tagGuid, (tag) ->
                reject tag if tag.type == "error"

                resolve tag
          
          note = 
            guid: noteMd.guid
            url: args.url
            tags: []
                     
          if fetchTags
            RSVP.all(fetchTags)
            .then (tags)->
              note.tags = tags

              args.callback note
          else
            args.callback note
        else
          $log.info "no note matching #{args.url}"
          args.callback null          
    
    saveNote: (args) ->
      new RSVP.Promise (resolve, reject) =>

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
            reject callback if callback.type == "error" or callback.name?.match /Exception/

            $log.info { msg: 'note updated', callback }

            resolve note
        else
          obj.noteStore.createNote obj.authToken, note, (callback) ->
            reject callback if callback.type == "error" or callback.name?.match /Exception/

            $log.info { msg: 'note saved', callback }
            note.guid = callback.guid

            resolve note

      # FIXME wrap in a promise so we can report errors during client-server interaction.


  obj
