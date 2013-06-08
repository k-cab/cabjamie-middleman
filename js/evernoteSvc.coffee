@appModule.factory 'evernote', ($log, $http) ->
  obj = 
    options:
      consumerKey: "sohocoke"
      consumerSecret: "80af1fd7b40f65d0"
      evernoteHostName: "https://sandbox.evernote.com"


    init: ->
      noteStoreTransport = new Thrift.BinaryHttpTransport(obj.noteStoreURL)
      noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
      @noteStore = new NoteStoreClient(noteStoreProtocol)

    ##

    initOauth: ->
      @oauth = OAuth
        consumerKey: obj.options.consumerKey,
        consumerSecret: obj.options.consumerSecret,
        # callbackUrl : "gotOAuth.html",
        # callbackUrl : window.location.origin + window.location.pathname + "#/stickers"
        callbackUrl : window.location
        signatureMethod : "HMAC-SHA1"

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

    login: ->
      # OAuth Step 1: Get request token
      obj.oauth.request
        method: "GET"
        url: @options.evernoteHostName + "/oauth"
        success: @loginSuccess
        failure: @loginFailure

    loginSuccess: (data) ->
      isCallBackConfirmed = false
      token = ""
      vars = data.text.split("&")
      i = 0

      while i < vars.length
        y = vars[i].split("=")
        if y[0] is "oauth_token"
          token = y[1]
        else if y[0] is "oauth_token_secret"
          @oauth_token_secret = y[1]
          localStorage.setItem "oauth_token_secret", y[1]
        else isCallBackConfirmed = true  if y[0] is "oauth_callback_confirmed"
        i++
      ref = undefined
      if isCallBackConfirmed
        
        # step 2 - send to the authorisation page
        window.location = obj.options.evernoteHostName + "/OAuth.action?oauth_token=" + token

        # ref.addEventListener "loadstart", (event) =>
        #   # set verifier , oauth token - redundant as we're doing this in the controller.

        #   loc = $location.url
        #   if loc.indexOf(obj.options.evernoteHostName + "/Home.action?gotOAuth.html?") >= 0
        #     index = undefined
        #     verifier = ""
        #     got_oauth = ""
        #     params = loc.substr(loc.indexOf("?") + 1)
        #     params = params.split("&")
        #     i = 0

        #     while i < params.length
        #       y = params[i].split("=")
        #       verifier = y[1]  if y[0] is "oauth_verifier"
        #       i++
        #   else got_oauth = y[1]  if y[0] is "gotOAuth.html?oauth_token"

        #   @getOauth()

      else
        
        # Step 4 : Get the final token
        # querystring = app.getQueryParams(data.text)
        # authTokenEvernote = querystring.oauth_token
        
        # authTokenEvernote can now be used to send request to the Evernote Cloud API
        
        # Here, we connect to the Evernote Cloud API and get a list of all of the
        # notebooks in the authenticated user's account:
        # noteStoreURL = querystring.edam_noteStoreUrl
        # noteStoreTransport = new Thrift.BinaryHttpTransport(noteStoreURL)
        # noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
        # noteStore = new NoteStoreClient(noteStoreProtocol)
        # noteStore.listNotebooks authTokenEvernote, ((notebooks) ->
        #   console.log notebooks
        # ), onerror = (error) ->
        #   console.log error

            
    # set the access token and GET /oauth. why?
    fetchEvernoteToken: (oauth_token, verifier, callback)->
      obj.oauth.setVerifier verifier
      obj.oauth.setAccessToken [oauth_token, localStorage.getItem("oauth_token_secret")]
      # obj.oauth.setAccessToken [oauth_token, ""]
      getData = oauth_verifier: verifier
      obj.oauth.request
        method: "GET"
        url: obj.options.evernoteHostName + "/oauth"
        success: (data)=>
          console.log "got evernote token!"
          @loginSuccess data
          
          # tidy the params
          params = obj.parseParams data         

          obj.noteStoreURL = params.noteStoreURL
          obj.authToken = params.authToken

          callback params
        failure: @loginFailure

    parseParams: (data) ->
      # get the shit tidied up
    
      queryParamsToMap data
      
    

    loginFailure: (error) ->
      console.log "error " + error.text

