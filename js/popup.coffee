@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
)

@AppCntl = ($scope, $log, userDataSource, runtime) ->

  ## controller actions

  $scope.addSticker = (sticker) ->
    $scope.page.addSticker sticker
    userDataSource.persist $scope.page

  $scope.addNewSticker = ->
    $log.info $scope.newSticker
    # post to server TODO
    # get delta of stickers TODO


  ## set up the page

  runtime.withCurrentResource (url)->

    userDataSource.fetch 'page', [ url ], (pageData) ->
      $log.info pageData
      
      page = new Page()
      page.url = pageData[0].get 'url'

      $scope.page = page
    
    
  ## set up stickers

  userDataSource.fetch 'stickers', [], (stickers) ->

    $scope.stickers = stickers

    $log.info JSON.stringify $scope.stickers
    $scope.$apply()



@Page = Parse.Object.extend "Page",
  url: 'stub-url'

  addSticker: (sticker) ->

    this.stickers = [] unless this.stickers
    this.stickers.push sticker unless _.include this.stickers, sticker

    # $log.info   # TODO factor out as angular module
    console.log
      obj: this
      msg: "stickers: #{this.stickers}"

  hasSticker: (sticker) ->
    if _.include this.stickers, sticker
      true
    else
      false

  # TODO fetch rather than instantiate - for the stickers already applied.
