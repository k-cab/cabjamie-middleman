appModule = angular.module("appModule", [], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
    controller: AppCntl
)


@AppCntl = ($scope) ->
  $scope.stickers = [
    {
        name: "stub-sticker-1",
    },
    {
        name: "stub-sticker-2",
    },
    {
        name: "stub-sticker-3"
    },
  ]

  $scope.page = null # TODO

  $scope.addSticker = (sticker) ->
    console.log
      obj: sticker
      msg: "add sticker"

    # $scope.page.addSticker sticker
