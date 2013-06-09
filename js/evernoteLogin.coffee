@EvernoteLoginCntl = ($scope, $location, $log, evernote) ->

  $scope.loginWithEvernote = ->
    window.evernoteAuthenticator.initialize()
    window.evernoteAuthenticator.loginWithEvernote()


  ## check if url has oauth results, use.


  # extract params
  params = $location.search()

  if params.oauth_token and params.oauth_verifier
    window.evernoteAuthenticator.postAuthenticationCallback = ->
      evernote.authToken = window.authTokenEvernote
      evernote.noteStoreURL = window.noteStoreURL
      evernote.init()

      # pass on to evernote svc
      $log.info
        msg: "got access token from evernote"
        svc: evernote
      
      # change $location fragment.
      $location.path '/stickers'
      $scope.$apply()

    window.evernoteAuthenticator.initialize()


  else
    $scope.loginWithEvernote()