@appModule.factory 'evernote', ($log, $http) ->
  obj = 
    options:
      consumerKey: "sohocoke"
      consumerSecret: "80af1fd7b40f65d0"
      evernoteHostName: "https://sandbox.evernote.com"


    init: ->
      obj.authToken = localStorage.getItem 'evernote_authToken'
      obj.noteStoreURL = localStorage.getItem 'evernote_noteStoreURL'

      throw "couldn't intialise from localStorage" unless obj.authToken and obj.noteStoreURL

      noteStoreTransport = new Thrift.BinaryHttpTransport(obj.noteStoreURL)
      noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
      @noteStore = new NoteStoreClient(noteStoreProtocol)

    ##

    listTags: (callback) ->
      @noteStore.listTags @authToken, callback
    
    createTag: (name) ->
      new RSVP.Promise (resolve, reject) ->
        tag = new Tag()
        tag.name = name
        @noteStore.createTag @authToken, tag, (results) ->
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

      @noteStore.findNotesMetadata @authToken, filter, 0, pageSize, spec, (notesMetadata) =>
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
          # @noteStore.getNote @authToken, guid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData, (note) ->
          #   args.callback note

          fetchTags = noteMd.tagGuids?.map (tagGuid) =>
            new RSVP.Promise (resolve, reject) =>
              @noteStore.getTag @authToken, tagGuid, (tag) ->
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

      thumbnailMd5 = b64_md5 thumbnailData.toString()
      thumbnailMd5Hex = hex_md5 thumbnailData.toString()

      data = new Data()
      data.size = thumbnailData.length
      data.body = thumbnailData
      data.bodyHash = thumbnailMd5

      resource = new Resource()
      resource.mime = 'image/jpeg'
      resource.data = data

      note.resources = [ resource ]

      note.content = """
        <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
        <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;">
          <div>#{args.content}</div>
          <en-media type="image/jpeg" hash="#{thumbnailMd5Hex}" width="300" height="300"/>
        </en-note>
        """

      if args.guid
        # update the note.

        note.guid = args.guid
        @noteStore.updateNote @authToken, note, (callback) ->
          throw callback if callback.type == "error" or callback.name?.match /Exception/

          $log.info { msg: 'note updated', callback }

          args.callback note if args.callback
      else
        @noteStore.createNote @authToken, note, (callback) ->
          throw callback if callback.type == "error" or callback.name?.match /Exception/

          $log.info { msg: 'note saved', callback }
          note.guid = callback.guid

          args.callback note if args.callback

      # FIXME wrap in a promise so we can report errors during client-server interaction.
  obj
