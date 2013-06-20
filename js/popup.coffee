# FIXME modularise mixed concerns (popup, stickers).

@appModule = angular.module("appModule", ['ui'], ($routeProvider, $locationProvider) ->
  $routeProvider
  .when "/stickers",
    templateUrl: "templates/stickers.html"
    controller: @AppCntl
  .when "/login",
    templateUrl: "templates/oauth.html"
  .otherwise
    redirectTo: "/stickers"
)

@UserPrefs = 
  sticker_prefix_pattern: /^##/
  sticker_prefix: '##'

  update: (key, val) ->
    if val == undefined
      throw "value for key #{key} is undefined"

    self[key] = val
    localStorage.setItem key, JSON.stringify val
  
  get: (k) ->
    val = localStorage.getItem k
    if val then JSON.parse(val) else null
  

that = this
@AppCntl = ($scope, $location, $log, $rootScope, userDataSource, runtime) ->

  ## controller actions

  $scope.toggleSticker = (sticker) ->
    doit = ->
      $rootScope.msg = "Saving..."

      unless $scope.page.hasSticker sticker
        $scope.addSticker sticker
      else
        $scope.removeSticker sticker

    doit()
    .then (result) ->
      $rootScope.msg = "Saved."
      $rootScope.$apply()

    .then null, (error) ->
      $log.error error
      $rootScope.msg =
        msg: "error"
        error: error
        url: $scope.page.url

  $scope.addSticker = (sticker) -> 
    $scope.page.addSticker sticker
    userDataSource.persist 'page', $scope.page

  $scope.removeSticker = (sticker) ->
    $scope.page.removeSticker sticker
    userDataSource.persist 'page', $scope.page

    # TODO decouple the writes from the user interaction, coalecse and schedule.

  
  $scope.createNewSticker = ->
    $scope.newSticker.name = UserPrefs.sticker_prefix + $scope.newSticker.name unless $scope.newSticker.name.match UserPrefs.sticker_prefix_pattern


    $log.info {msg: "new sticker", sticker:$scope.newSticker}

    # userDataSource.persist 'sticker', $scope.newSticker, (newSticker) ->
    #   $scope.stickers.push newSticker
    #   $scope.$apply()
    
    $scope.stickers.push $scope.newSticker
    $scope.newSticker = null

    # TODO error case

    # $scope.fetchStickers()
    # FIXME get delta of stickers


  $scope.sortableOptions =
    stop: (e, ui)->
      $log.info "drag-drop finished."
      $scope.saveStickerOrder()

  $scope.saveStickerOrder = ->
    # persist the sticker order list.
    that.UserPrefs.update 'stickerOrder',
      $scope.stickers.map (sticker)-> sticker.name

  $scope.orderedStickers = (stickers)->
    # apply the sticker order list.
    stickerOrder = that.UserPrefs.get 'stickerOrder'
    stickerOrder = [] if ! stickerOrder

    orderedStickers = stickerOrder.map (name) ->
      stickers.filter((sticker) -> sticker.name == name)[0]
    orderedStickers = _.without orderedStickers, undefined

    # add stickers not found in order list at the end.
    stickers.map (sticker) ->
      orderedStickers.push sticker unless _.contains orderedStickers, sticker

    orderedStickers


  $scope.fetchPage = ->

    promise = new RSVP.Promise (resolve, reject) ->
      url = if $scope.page 
          $scope.page.url 
        else
          window.location.href

      runtime.pageForUrl( url )
      .then (pageSpec)->
        userDataSource.fetchPage pageSpec
      .then (page) ->
        try
          $scope.page = page
          $scope.$apply()

          # chrome.pageCapture.saveAsMHTML( { tabId: page.id } )
          # .then (mhtmlData) ->
          #   page.pageContent = mhtmlData
            # $log.info { msg: " got the visual representation.", mhtml:mhtmlData }

          runtime.capturePageThumbnail(page)
          .then (dataUrl) ->
            $log.info { msg: " got the visual representation.", dataUrl }

            $scope.page.thumbnailUrl = dataUrl

            resolve $scope.page

        catch e
          reject e

  $scope.fetchStickers = (page)->    

    promise = new RSVP.Promise (resolve, reject) ->
      userDataSource.fetchStickers null, (stickers) ->
        try

          orderedStickers = $scope.orderedStickers stickers

          $scope.stickers = orderedStickers

          # this seems redundant now, but sweep for regressions
          # $scope.$apply()

          resolve $scope.stickers
        catch e
          reject e


  $scope.update = ->
    $rootScope.msg = "Fetching data..."

    RSVP.all([ 
      $scope.fetchPage(), 
      $scope.fetchStickers()
    ])
    .then ->
      $rootScope.msg = ""
      $scope.$apply()
    .then null, (error) ->
      $log.error error
      throw error

    return null


  $scope.login = ->
    # save the location so the oauth module can redirect back.
    $location.path "/login"


  $scope.showPageDetails = ->
    ! runtime.hasRealPageContext()


  ## doit

  try 
    $rootScope.msg = "Test msg."

    userDataSource.init()
    $scope.update()
  catch e
    $rootScope.msg = e

    # do the login thing.
    localStorage.setItem "oauth_success_redirect_path", location.href
    $scope.login()

    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  
  