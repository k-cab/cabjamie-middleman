# other svc's depend on this.
@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
)

# controller used inside the iframe - i.e. managed by different app.
@EvernoteLoginCntl = (
  $scope, $rootScope, $location, $log, 
  globalsSvc, evernoteSvc) ->

  $scope.loginWithEvernote = ->
    window.evernoteAuthenticator.initialize()
    window.evernoteAuthenticator.loginWithEvernote()


  #### doit

  ## check if url has oauth results, use if they exist.

  params = $location.search()

  if params.oauth_token and params.oauth_verifier

    # we've been redirected back from Evernote oauth.

    window.evernoteAuthenticator.postAuthenticationCallback = ->
      # pass on to evernote svc HACK
      localStorage.setItem 'evernote_authToken', window.authTokenEvernote
      localStorage.setItem 'evernote_noteStoreURL', window.noteStoreURL

      evernoteSvc.init()
      $rootScope.authentication.setLoggedIn()

      $log.info
        msg: "got access token from evernote"
        svc: evernoteSvc
      
      # # change $location fragment.
      # $location.path '/stickers'
      # $scope.$apply()

      # set the parent's evernoteSvc. framed architecture is really embedding itself here..
      window.parent.evernoteSvc = evernoteSvc

      redirect_url = localStorage.getItem "oauth_success_redirect_path"

      $log.info "redirecting parent window to #{redirect_url}"
      window.parent.location.href = redirect_url


    evernoteAuthenticator.initialize()


  else
    # start the oauth workflow.

    new Q.fcall ->
      result = $scope.loginWithEvernote()
      
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


