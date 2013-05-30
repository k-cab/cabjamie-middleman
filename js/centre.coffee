@appModule = angular.module("appModule", [], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
)

Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm");


@AppCntl = ($scope, $log, userDataSource) ->
  ## controller actions

  $scope.navigateTo = (sticker) ->
    $scope.selectedSticker = sticker

  $scope.fetchItems = (sticker) ->
    userDataSource.fetch 'items', [ sticker ], (items)->
      $log.info items
      sticker.items = items
      $scope.$apply()

  ## load the stickers

  userDataSource.fetch 'stickers', null, (stickers) ->

    $scope.stickers = stickers

    $log.info JSON.stringify $scope.stickers


    ## brute-force fetch of items for all stickers
    # FIXME make it based on a promise.
    $scope.stickers.forEach (sticker) ->
      $scope.fetchItems sticker

