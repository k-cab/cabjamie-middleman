window.app =
  consumerKey: "sohocoke"
  consumerSecret: "80af1fd7b40f65d0"
  evernoteHostName: "https://sandbox.evernote.com"

  loginWithEvernote: ->
    options =
      consumerKey: app.consumerKey
      consumerSecret: app.consumerSecret
      callbackUrl: window.location # this filename doesn't matter in this example
      signatureMethod: "HMAC-SHA1"

    oauth = OAuth(options)
    
    # OAuth Step 1: Get request token
    oauth.request
      method: "GET"
      url: app.evernoteHostName + "/oauth"
      success: app.success
      failure: app.failure


  success: (data) ->
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
      
      # step 2
      ref = null
      window.location = app.evernoteHostName + "/OAuth.action?oauth_token=" + token
      ref.addEventListener "loadstart", (event) ->
        loc = event.url
        if loc.indexOf(app.evernoteHostName + "/Home.action?gotOAuth.html?") >= 0
          index = undefined
          verifier = ""
          got_oauth = ""
          params = loc.substr(loc.indexOf("?") + 1)
          params = params.split("&")
          i = 0

          while i < params.length
            y = params[i].split("=")
            verifier = y[1]  if y[0] is "oauth_verifier"
            i++
        else got_oauth = y[1]  if y[0] is "gotOAuth.html?oauth_token"
        
        # step 3
        oauth.setVerifier verifier
        oauth.setAccessToken [got_oauth, localStorage.getItem("oauth_token_secret")]
        getData = oauth_verifier: verifier
        ref.close()
        oauth.request
          method: "GET"
          url: app.evernoteHostName + "/oauth"
          success: app.success
          failure: app.failure


    else
      
      # Step 4 : Get the final token
      querystring = app.getQueryParams(data.text)
      authTokenEvernote = querystring.oauth_token
      
      # authTokenEvernote can now be used to send request to the Evernote Cloud API
      
      # Here, we connect to the Evernote Cloud API and get a list of all of the
      # notebooks in the authenticated user's account:
      noteStoreURL = querystring.edam_noteStoreUrl
      noteStoreTransport = new Thrift.BinaryHttpTransport(noteStoreURL)
      noteStoreProtocol = new Thrift.BinaryProtocol(noteStoreTransport)
      noteStore = new NoteStoreClient(noteStoreProtocol)
      noteStore.listNotebooks authTokenEvernote, ((notebooks) ->
        console.log notebooks
      ), onerror = (error) ->
        console.log error


  failure: (error) ->
    console.log "error " + error.text


## check if url has oauth results, use.

# extract params
$location = angular.element('body').injector().get('$location')
params = $location.search()

if params.oauth_token and params.auth_verifier
	# pass on to evernote svc
	evernote = angular.element('body').injector().get('evernote')

	# change $location
	$location.path '/stickers'