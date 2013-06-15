  @appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
    # $routeProvider.when "/",
    #   # templateUrl: "templates/index.html"
    #   controller: EvernoteLoginCntl
  )

  @EvernoteLoginCntl = ($scope, $location, $log, evernote) ->

    $scope.loginWithEvernote = ->
      window.evernoteAuthenticator.initialize()
      window.evernoteAuthenticator.loginWithEvernote()


    ## do the business.

    ## check if url has oauth results, use if they exist.

    params = $location.search()

    if params.oauth_token and params.oauth_verifier

      # we've been redirected back from Evernote oauth.

      window.evernoteAuthenticator.postAuthenticationCallback = ->
        # pass on to evernote svc HACK
        localStorage.setItem 'evernote_authToken', window.authTokenEvernote
        localStorage.setItem 'evernote_noteStoreURL', window.noteStoreURL

        evernote.init()

        $log.info
          msg: "got access token from evernote"
          svc: evernote
        
        # # change $location fragment.
        # $location.path '/stickers'
        # $scope.$apply()

        # set the parent's evernote. framed architecture is really embedding itself here..
        window.parent.evernote = evernote

        redirect_url = localStorage.getItem "oauth_success_redirect_path"

        $log.info "redirecting parent window to #{redirect_url}"
        window.parent.location.href = redirect_url

      # evernoteAuthenticator.callbackUrl = 
      evernoteAuthenticator.initialize()


    else
      # start the oauth workflow.


      new RSVP.Promise (resolve, reject)->
        result = $scope.loginWithEvernote()
        resolve 
      .then null, (err) ->
        $log.error err

        # TODO prompt user action.


# BEGIN REFACTORABLE      

myRequire = (libfiles...) ->
  loads = libfiles.map (file) ->
    # return the promise to load the script file.
    $q.promise ->
      # call vendor-specific promise-returning load routine.
      # file

  $q.all loads

# myRequire(
#   'rsvp.js'
# ).then ->

# END REFACTORABLE


