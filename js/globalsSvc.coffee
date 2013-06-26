that = this

@appModule.factory 'globalsSvc', ($log, $rootScope, $location) ->
  

  $rootScope.authentication =
    
    loginAction:
      url: '#/login'
      message: 'Login'

    logoutAction:
      url: '#/logout'      
      message: 'Logout'

    nextAction: @loginAction

    
  obj = 

    doit: ->

      # all state refreshes.
      Q.fcall ->
        that.appModule.userPrefs.apply 'production'
        obj.update()
      .fail (e) ->
        # HACK check for authentication error and redirect.
        if e.errorType == 'authentication'
          obj.login()
        else
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
      that.appModule.userPrefs.userDataSource.init()
      that.appModule.stickersC.update()


    login: ->
      # save the location so the oauth module can redirect back.
      localStorage.setItem "oauth_success_redirect_path", location.href

      $location.path "/login"
      $rootScope.$apply()


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

