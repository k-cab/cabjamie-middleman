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
  $log, $location, $resource
  globalsSvc) ->

    $scope.doLogin = ->
      # authentication_endpoint = $resource 'http://localhost\\:8081/authentication', {},
      #   post:
      #     method: 'POST'
      #     params:
      #       userName: $scope.userName
      #       password: $scope.password
      #   initiate:
      #     method: 'GET'

      # phase 2: return mk-token for client to use to access en data, map mk-token to en-token on server side.

      # phase 1 impl
      # first check if access details available INSECURE
      authenticationDetails = $resource('http://localhost\\:8081/authentication/details').get()
      authenticationDetails.$then ->
        if authenticationDetails
          app.userPrefs.authToken = authenticationDetails.authToken
          app.userPrefs.noteStoreURL = authenticationDetails.noteStoreURL
          $rootScope.authentication.setLoggedIn()

          $location.path '/'
      .then ->
        if app.userPrefs.authToken
          return

        location.href = 'http://localhost:8081/authentication'          
      # ERRCASE

      # TODO server-side: save referer as redirect url
      # on authentication/redirect, redirect to redirect_url
      # new endpoint to retrieve token, pending security

    if $location.path().match /logout/
      $rootScope.authentication.setLoggedOut()
      
    else if $location.path().match /login$/

      # # save the location so the oauth module can redirect back.
      # # FIXME establish a contract between an initiator and this module.
      # initialPath = $location.absUrl().replace(/#.*/,'')
      # localStorage.setItem "oauth_success_redirect_path", initialPath

      # TODO eventually make the control trigger this action.
      $scope.doLogin()
