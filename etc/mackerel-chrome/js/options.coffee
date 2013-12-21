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

    $scope.userPrefs = userPrefs

    $scope.showPreview = (userPrefs.get('previewClass') == 'shown')

    $scope.onShowPreviewChange = ->

      # the preview-class controls display of preview stuff.
      $scope.previewClass = 'shown'
      userPrefs.set 'previewClass', 
        if userPrefs.get('previewClass') == 'shown'
          ''
        else
          'shown'

    $scope.options = 
      env:
        data: [ 'dev', 'production' ]
        selection: userPrefs.env

      # dataService:
      #   data: [ 'stubDataSvc', 'evernoteSvc' ]
      #   selection: userPrefs.

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
