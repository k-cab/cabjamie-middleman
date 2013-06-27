# make a controller that manages states on the scope running through the user's lifecycle.

#  states:
# logged out
# logged in

# transitions:
# logging in
# logging out

# some details may be added due to oauth redirection schemes.


angular.module( 'appModule' )
.controller 'AuthenticationCntl',
  ($scope, $rootScope,
  $log, $location
  globalsSvc) ->

  	# login, logout ops are defined on $rootScope, so this only serves as a dep-loading mechanism and actions invoked on path change.

  	if $location.path().match /logout/
  		$rootScope.authentication.setLoggedOut()
  	else if $location.path().match /login/
		  # save the location so the oauth module can redirect back.
		  initialPath = $location.absUrl().replace(/#.*/,'')
		  localStorage.setItem "oauth_success_redirect_path", initialPath

		  # after the auth protocol succeeds, call $rootScope.authentication.setLoggedIn

	  # CLEANUP redundant after $rootScope.authentication set up during globalsSvc.

	  # cntl =
	  #   status: 'stub login status'

	  #   login: ->
	  #     # initiate crazy login sequence using the oauth controller
	      
	  #   logout: ->
	  #     # discard the oauth token. should prevent crazy redirects. TODO pull the handling out.

