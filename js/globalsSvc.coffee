that = this

@appModule.factory 'globalsSvc', ($log, $rootScope, $location,
  userPrefs) ->
  
  # set up an authentication object under root scope, as ui needs to invoke ops. all controllers must declare this service as an injected dep in order to make authentication flows work.
  $rootScope.authentication =
    
    loginAction:
      url: '#/login'
      message: 'Login'

    logoutAction:
      url: '#/logout'      
      message: 'Logout'

    setLoggedIn: ->
      @loggedIn = true
      @nextAction = @logoutAction

    setLoggedOut: ->
      @loggedIn = false
      @nextAction = @loginAction

  $rootScope.authentication.loggedIn = false
  $rootScope.authentication.nextAction = $rootScope.authentication.loginAction


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
      $rootScope.authentication.setLoggedIn()
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

      # expose it on the app module. there should be a better way to inject the right impl, but it has to be controllable from this method.
      that.appModule.userDataSource = @userDataSource

    needsIntro: ->
      nextIntroVal = @get 'nextIntro'
      nextIntroVal? new Date(nextIntroVal).isPast()

    setFinishedIntro: ->
      @update 'nextIntro', @nextDate()

    nextDate: ->
      Date.tomorrow() # DEV


# REFACTOR
Date.tomorrow = ->
  today = new Date()
  tomorrow = new Date()
  tomorrow.setDate(today.getDate()+1)

Date::isPast = ->
  now = new Date()
  @.getTime() < now.getTime()
