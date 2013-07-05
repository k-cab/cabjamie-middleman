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

    # the preview-class controls display of preview stuff.
    $scope.previewClass = 'shown'

    $scope.options = 
      env:
        data: [ 'dev', 'production' ]
        selection: userPrefs.env

      localStorage: 
        data: _.map Object.keys(localStorage), (e)-> e + ": " + localStorage.getItem e

        actions: [
          name: 'reset all'
          func: -> 
            $log.info "clearing everything in localStorage"
            for i in localStorage
              localStorage.clear i
        ]

    $scope.chooseKeyVal = (key, val) ->
      $log.info 'todo'
      switch key
        when 'env'
          userPrefs.set 'env', val

        # other handling logic here.

      # update the selection.
      $scope.options[key].selection = val


    # TODO show userPrefs data
