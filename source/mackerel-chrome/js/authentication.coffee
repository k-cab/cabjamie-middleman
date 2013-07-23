# make a controller that manages states on the scope running through the user's lifecycle.

#  states:
# logged out
# logged in

# transitions:
# logging in
# logging out

# some details may be added due to oauth redirection schemes.

app = @appModule

angular.module( 'appModule' )
.controller 'AuthenticationCntl',
  ($scope, $rootScope,
  $log, $location, $resource, 
  globalsSvc, userPrefs, envs) ->

    $scope.loginForm =
      username: userPrefs.get 'username'


    $scope.doLogin = ->

      # TODO phase 2: return mk-token for client to use to access en data, map mk-token to en-token on server side.

      userPrefs.set 'username', $scope.loginForm.username

      globalsSvc.setupRestangular()

      # phase 1 impl
      # first check if access details available INSECURE
      serverLoc = envs[userPrefs.get 'env'].apiServer
      authenticationDetails = $resource(serverLoc.replace(/:(\d+)/, '\\:$1') + '/authentication/details').get()
      authenticationDetails.$then ->
        if authenticationDetails
          # save authentication details, updated login status and redirect

          app.userPrefs.authToken = authenticationDetails.authToken
          app.userPrefs.noteStoreURL = authenticationDetails.noteStoreURL
          $rootScope.authentication.setLoggedIn()

          $location.path '/'
      .then ->
        if app.userPrefs.authToken
          return

        # start authentication dialogue with server
        location.href = serverLoc + '/authentication'          
      # ERRCASE

      # TODO server-side: save referer as redirect url
      # on authentication/redirect, redirect to redirect_url
      # new endpoint to retrieve token, pending security

    if $location.path().match /logout/
      $rootScope.authentication.setLoggedOut()
      
    else if $location.path().match /login$/

      console.log 'login requested.'

      # NICETOHAVE save the referer so the oauth module can redirect back.
