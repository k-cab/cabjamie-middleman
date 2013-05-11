appModule = angular.module("appModule", [], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
    controller: AppCntl
)

Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm");

@Page = Parse.Object.extend "Page",
  url: 'stub-url'

  addSticker: (sticker) ->
    console.log
      obj: sticker
      msg: "add sticker to #{this.url}"

    this.save null,
      success: (page) ->
        console.log "save successful"
      error: (page) ->
        console.log "save failed"


@AppCntl = ($scope) ->
  # TODO factor out the class.
  # TODO sync with rest backend.
  $scope.page = new Page()

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

  $scope.addSticker = (sticker) ->
    $scope.page.addSticker sticker
