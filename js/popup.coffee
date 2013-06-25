# FIXME modularise mixed concerns (popup, stickers).

# DEV
Q.longStackSupport = true

@appModule = angular.module("appModule", ['ui'], ($routeProvider, $locationProvider) ->
  $routeProvider
  .when "/",
    templateUrl: "templates/stickers.html"
    controller: 'AppCntl'
  .when "/login",
    templateUrl: "templates/oauth.html"
    # controller: @appCntl.loginCntl
  .when "/stickers",
    templateUrl: "templates/stickers.html"
    controller: 'StickersCntl'
  .otherwise
    redirectTo: "/"
)


that = this

@UserPrefs = @appModule.factory 'userPrefs', ($log
  stubDataSvc, evernoteSvc) ->

  @stubDataSvc = stubDataSvc
  evernoteSvc = evernoteSvc

  update: (key, val) ->
    if val == undefined
      throw "value for key #{key} is undefined"

    @[key] = val
    localStorage.setItem key, JSON.stringify val
  
  get: (k) ->
    val = localStorage.getItem k
    if val and val != 'undefined'
      # update my properties.
      @[k] = val
    else
      # shouldn't set - it would be circular.

      # default to current properties.
      val = @[k]

    if val
      try 
        parsed = JSON.parse(val)
      catch e
        return val
    else
      console.log "returning null for '#{k}'"
      null


  apply: (env = 'production')->
    console.log "applying env '#{env}'"

    @userDataSource = @[env].userDataSource

    # update all dependents.
    @userDataSource.init()
    that.appModule.stickersC.update()


  ## defaults.

  env: 'production'
  
  sticker_prefix_pattern: /^##/
  sticker_prefix: '##'

  userDataSource: null


  ## envs.

  production:
    userDataSource: evernoteSvc

  dev:
    userDataSource: stubDataSvc



@AppCntl = ($scope, $location, $log, $rootScope, 
  runtime,
  stubDataSvc, evernoteSvc
  ) ->

  # that.appModule.runtime = runtime

  # that.appModule.stubDataSvc = stubDataSvc
  # that.appModule.evernoteSvc = evernoteSvc
  
  # REFACTOR
  that.appModule.env = (newEnv, updatable) ->
    # set deps.

    if newEnv == 'dev'
      that.appModule.userDataSource = stubDataSvc
    else
      that.appModule.userDataSource = evernoteSvc


    # all state refreshes.
    Q.fcall ->
      that.appModule.userDataSource.init()
      updatable.update()
    .fail (e) ->
      # HACK check for authentication error and redirect.
      if e.errorType == 'authentication'
        $scope.login()
      else
        $rootScope.handleError e
        $rootScope.$apply()
    .done()


  $rootScope.handleError = (e) ->
    $log.error e

    $rootScope.msg = "error: #{e}"
    $rootScope.error = e


  ## REFACTOR
  ## workflow

  $scope.login = ->
    # save the location so the oauth module can redirect back.
    localStorage.setItem "oauth_success_redirect_path", location.href

    $location.path "/login"
    $scope.$apply()


  #### doit
  Q.fcall ->
    $location.path( "/stickers")
  .done()

  # do the login thing.
  # $scope.login()

    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  




