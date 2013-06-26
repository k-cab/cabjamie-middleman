that = this
@appModule.factory 'globalsSvc', ($log, $rootScope) ->
  
  obj = 

    doit: ->

      # all state refreshes.
      Q.fcall ->
        that.appModule.userPrefs.apply 'production'
        obj.update()
      .fail (e) ->
        # FIXME we need another place where we can use $scope, $rootscope,
        # or need to remove these deps.
        # 
        # # HACK check for authentication error and redirect.
        # if e.errorType == 'authentication'
        #   $scope.login()
        # else
        #   $rootScope.handleError e
        #   $rootScope.$apply()

        obj.handleError e

      .done()


    update: ->
      # update all dependents.
      that.appModule.userPrefs.userDataSource.init()
      that.appModule.stickersC.update()


    handleError: (e) ->
      $log.error e

      $rootScope.msg = "error: #{JSON.stringify e}"
      $rootScope.error = e

      $rootScope.$apply()
      
      # console.warn { msg: 'Exception!!', obj:e }

