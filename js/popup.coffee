@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
)

@AppCntl = ($scope, $log, userDataSource, runtime) ->
  ## controller actions

  $scope.addSticker = (sticker) ->
    $scope.page.addSticker sticker
    userDataSource.persist $scope.page

    # TODO relay result back to ui.


  ## set up the page

  $scope.page = new Page()

  runtime.withCurrentResource (url)->
    $scope.page.url = url
    # $scope.$apply()  # this throws when out of chrome.
    
    
  ## set up stickers

  userDataSource.fetch 'stickers', [], (stickers) ->

    $scope.stickers = stickers

    $log.info JSON.stringify $scope.stickers
    $scope.$apply()


@Page = Parse.Object.extend "Page",
  url: 'stub-url'

  addSticker: (sticker) ->

    this.stickers = [] unless this.stickers
    this.stickers.push sticker unless this.stickers.include? sticker

    # $log.info   # TODO factor out as angular module
    console.log
      obj: this
      msg: "stickers: #{this.stickers}"


