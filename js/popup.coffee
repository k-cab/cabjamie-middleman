#FIXME time to clean up the backbone / prop api mismatch.

@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
)

@AppCntl = ($scope, $log, userDataSource, runtime) ->

  ## controller actions

  $scope.addSticker = (sticker) -> 
    $scope.page.addSticker sticker
    userDataSource.persist 'page', $scope.page

  $scope.createNewSticker = ->
    $log.info $scope.newSticker

    $scope.stickers.push $scope.newSticker

    userDataSource.persist 'sticker', $scope.newSticker
    # TODO error case

    # $scope.fetchStickers()
    # FIXME get delta of stickers

  $scope.fetchPage = ->

    promise = new RSVP.Promise (resolve, reject) ->
      runtime.withCurrentResource (url)->
        userDataSource.fetch 'page', [ url ], (pages) ->
          $log.info pages

          page = new Page()
          page.url = pages[0].url
          page.stickers = pages[0].fetchStickers()

          $scope.page = page

          resolve $scope.page

          # TODO error case


  $scope.fetchStickers = ->    

    promise = new RSVP.Promise (resolve, reject) ->
      userDataSource.fetch 'stickers', [], (stickers) ->
        $log.info JSON.stringify stickers

        $scope.stickers = stickers

        $scope.$apply()

        resolve stickers

        # TODO error case


  RSVP.all([ $scope.fetchPage(), $scope.fetchStickers() ])
  .then ->
    $scope.$apply()
  .then null, (error) ->
    $log.error error

  return null

  # FIXME stickered status for page doesn't show up initially.


# FIXME isolate Parse-specifics into userDataSource.
class Page
  url: 'stub-url'

  addSticker: (sticker) ->

    this.stickers = [] unless this.stickers
    this.stickers.push sticker unless _.include this.stickers, sticker

    # $log.info   # TODO factor out as angular module
    console.log
      obj: this
      msg: "stickers: #{this.stickers}"

  hasSticker: (stickerName) ->
    if _.include this.stickers?.map((e) -> e.name), stickerName
      true
    else
      false
