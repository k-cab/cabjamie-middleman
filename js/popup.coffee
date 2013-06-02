#FIXME time to clean up the backbone / prop api mismatch.

@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
)

@AppCntl = ($scope, $log, userDataSource, runtime) ->

  ## controller actions

  $scope.toggleSticker = (sticker) ->
    unless $scope.page.hasSticker sticker
      $scope.addSticker sticker
    else
      $scope.removeSticker sticker

  $scope.addSticker = (sticker) -> 
    $scope.page.addSticker sticker
    userDataSource.persist 'page', $scope.page

  $scope.removeSticker = (sticker) ->
    $scope.page.removeSticker sticker
    userDataSource.persist 'page', $scope.page

    # TODO decouple the writes from the user interaction, coalecse and schedule.

  
  $scope.createNewSticker = ->
    $log.info {msg: "new sticker", sticker:$scope.newSticker}

    userDataSource.persist 'sticker', $scope.newSticker, (newSticker) ->
      $scope.stickers.push newSticker
      $scope.$apply()
      
    # TODO error case

    # $scope.fetchStickers()
    # FIXME get delta of stickers

  $scope.fetchPage = ->

    promise = new RSVP.Promise (resolve, reject) ->
      runtime.withCurrentResource (url)->
        userDataSource.fetch 'page', [ url ], (pages) ->
          page = pages[0]
          $scope.page = page

          resolve $scope.page

          # TODO error case


  $scope.fetchStickers = (page)->    

    promise = new RSVP.Promise (resolve, reject) ->
      userDataSource.fetch 'stickers', [], (stickers) ->

        $scope.stickers = stickers

        # this seems redundant now, but sweep for regressions
        # $scope.$apply()

        resolve stickers

        # TODO error case


  RSVP.all([ $scope.fetchPage(), $scope.fetchStickers() ])
  .then ->
    $scope.$apply()
  .then null, (error) ->
    $log.error error

  return null

  # FIXME stickered status for page doesn't show up initially.
