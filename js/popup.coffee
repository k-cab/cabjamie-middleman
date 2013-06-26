
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

  that.appModule.userPrefs = 
    stubDataSvc: stubDataSvc
    evernoteSvc: evernoteSvc

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



# no longer relevant after routing changes.
@AppCntl = ($scope, $location, $log, $rootScope, 
  runtime,
  stubDataSvc, evernoteSvc
  ) ->

  # that.appModule.runtime = runtime

  # that.appModule.stubDataSvc = stubDataSvc
  # that.appModule.evernoteSvc = evernoteSvc
  


  ## REFACTOR
  ## workflow

  $scope.login = ->
    # save the location so the oauth module can redirect back.
    localStorage.setItem "oauth_success_redirect_path", location.href

    $location.path "/login"
    $scope.$apply()


  #### doit
  Q.fcall ->
    # TODO check if login needed
    $scope.login()
    # else
    #   $location.path( "/stickers")
  .done()


    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  




