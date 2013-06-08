@appModule.factory 'evernote', ($log, $http) ->
	obj = 
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
       
      filter = new NoteFilter()
      filter.order = NoteSortOrder.UPDATED
      filter.words = "sourceURL:#{args.url}"
      
      spec = new NotesMetadataResultSpec()
      spec.includeTitle = true
      spec.includeTagGuids = true

      # sourceApplication TODO

      @noteStore.findNotesMetadata @authToken, filter, 0, pageSize, spec, (notesMetadata) =>
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

          fetchTags = noteMd.tagGuids.map (tagGuid) =>
            new RSVP.Promise (resolve, reject) =>
              @noteStore.getTag @authToken, tagGuid, (tag) ->
                resolve tag
            
          RSVP.all(fetchTags)
          .then (tags)->
            note = 
              guid: noteMd.guid
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

      if args.guid
        # update the note.

        note.guid = args.guid
        @noteStore.updateNote @authToken, note, (callback) ->
          $log.info { msg: 'note updated', callback }

          args.callback note if args.callback
      else
        @noteStore.createNote @authToken, note, (callback) ->
          $log.info { msg: 'note saved', callback }
          note.guid = callback.guid

          args.callback note if args.callback

  ##

  obj.init()
  obj

