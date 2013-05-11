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

  # TODO factor out the class.
  # TODO sync with rest backend.
  $scope.page = 
    url: 'stub-url'

    addSticker: (sticker) ->
      console.log
        obj: sticker
        msg: "add sticker to #{self.url}"
  

  $scope.addSticker = (sticker) ->

    $scope.page.addSticker sticker
