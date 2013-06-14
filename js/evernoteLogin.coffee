@EvernoteLoginCntl = ($scope, $location, $log, evernote) ->

  $scope.loginWithEvernote = ->
    window.evernoteAuthenticator.initialize()
    window.evernoteAuthenticator.loginWithEvernote()


  ## check if url has oauth results, use if they exist.

  params = $location.search()

  if params.oauth_token and params.oauth_verifier

    # we've been redirected back from Evernote oauth.

    window.evernoteAuthenticator.postAuthenticationCallback = ->
      # pass on to evernote svc
      localStorage.setItem 'evernote_authToken', window.authTokenEvernote
      localStorage.setItem 'evernote_noteStoreURL', window.noteStoreURL

      evernote.init()

      $log.info
        msg: "got access token from evernote"
        svc: evernote
      
      # change $location fragment.
      $location.path '/stickers'
      $scope.$apply()


    window.evernoteAuthenticator.initialize()


  else
    # start the oauth workflow.

    $scope.loginWithEvernote()