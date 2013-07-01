@appModule = angular.module "appModule", ['ui', 'ngResource'], ($routeProvider, $locationProvider) ->
    # routing
    $routeProvider.when "/",
      templateUrl: 'templates/options.html'
      controller: 'AppCntl'

    .otherwise
      redirectTo: "/"


@appModule.controller 'AppCntl', 
  ($scope, $log, $location, $resource,
    userPrefs
  ) ->
    $scope.options = 
      env:
        [ 'dev', 'production' ]
      localStorage: ['localStorageData']

    $scope.chooseKeyVal = (key, val) ->
      $log.info 'todo'
      switch key
        when 'env'
          userPrefs.set 'env', val

        # other handling logic here.


    # show userPrefs data

    # show localstorage
    # actions: clear
    # item actions: clear
