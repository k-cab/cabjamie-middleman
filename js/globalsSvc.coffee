that = this

@appModule.factory 'globalsSvc', ($log, $rootScope, $location,
  userPrefs) ->
  

  $rootScope.authentication =
    
    loginAction:
      url: '#/login'
      message: 'Login'

    logoutAction:
      url: '#/logout'      
      message: 'Logout'

    nextAction: @loginAction

    loggedIn: false

    login: ->
      # save the location so the oauth module can redirect back.
      localStorage.setItem "oauth_success_redirect_path", location.href

      $location.path "/login"
      $rootScope.$apply()

    setLoggedin: ->
      @loggedIn = true

      # TODO update next action.


  # looking redundant - just use rootscope?
  obj = 

    doit: ->

      # all state refreshes.
      Q.fcall ->
        userPrefs.apply 'production'
        obj.update()
      .fail (e) ->
        # HACK check for authentication error and redirect.
        # if e.errorType == 'authentication'
        #   $rootScope.authentication.login()
        # else
        #   obj.handleError e

        obj.handleError e
      .done()


    handleError: (e) ->
      $log.error e

      $rootScope.msg = "error: #{e}"
      $rootScope.error = e

      $rootScope.$apply()

      # console.warn { msg: 'Exception!!', obj:e }


    update: ->
      # update all dependents.
      userPrefs.userDataSource.init()
      $rootScope.authentication.setLoggedin()
      that.appModule.stickersC?.update()



@appModule.factory 'userPrefs', ($log
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
      that.appModule.userDataSource = @userDataSource

