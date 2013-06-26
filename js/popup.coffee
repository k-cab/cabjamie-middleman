
# DEV
Q.longStackSupport = true

@appModule = angular.module "appModule", ['ui'], ($routeProvider, $locationProvider) ->
  $routeProvider
  .when "/",
    templateUrl: "templates/stickers.html"
    controller: 'AppCntl'
  .when "/login",
    templateUrl: "templates/oauth.html"
    controller: 'AuthenticationCntl'
  .when "/logout",
    templateUrl: "templates/authentication.html"
    controller: 'AuthenticationCntl'
  .when "/stickers",
    templateUrl: "templates/stickers.html"
    controller: 'StickersCntl'
  .otherwise
    redirectTo: "/"
.config ($compileProvider)->
  # prevent url's being prefixed with 'unsafe:'
  # REFACTOR to runtime
  $compileProvider.urlSanitizationWhitelist(/^\s*(https?|chrome-extension):/) 


# no longer relevant after routing changes.
@AppCntl = ($scope, $location, $log, $rootScope,
  globalsSvc, 
  runtime,
  stubDataSvc, evernoteSvc
  ) ->

  # that.appModule.runtime = runtime

  # that.appModule.stubDataSvc = stubDataSvc
  # that.appModule.evernoteSvc = evernoteSvc
  


  #### doit
  Q.fcall ->
    # update will set authentication status
    globalsSvc.doit()
    # globalsSvc.update()
  .then ->
    if $rootScope.authentication.loggedIn
      $location.path "/stickers"
    else
      $location.path "/login"

    $rootScope.$apply()

  .done()


    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  




