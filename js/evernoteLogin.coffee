@EvernoteLoginCntl = ($scope, $location, $log, evernote) ->

  $scope.loginWithEvernote = ->
    evernote.login()


  ## check if url has oauth results, use.

  # extract params
  params = $location.search()

  evernote.initOauth()

  if params.oauth_token and params.oauth_verifier
    evernote.init()
    evernote.fetchEvernoteToken params.oauth_token, params.oauth_verifier, (params) ->
      # pass on to evernote svc
      $log.info
        msg: "got access token from evernote"
        svc: evernote

      # change $location fragment.
      $location.path '/stickers'
  else
    $scope.loginWithEvernote()