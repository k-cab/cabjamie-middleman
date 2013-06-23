# FIXME modularise mixed concerns (popup, stickers).

@UserPrefs = 
  update: (key, val) ->
    if val == undefined
      throw "value for key #{key} is undefined"

    @[key] = val
    localStorage.setItem key, JSON.stringify val
  
  get: (k) ->
    val = localStorage.getItem k
    if val and val != 'undefined'
      # update my properties.
      @[k] = val
    else
      # shouldn't set - it would be circular.

      # default to current properties.
      val = @[k]

    if val
      try 
        parsed = JSON.parse(val)
      catch e
        return val
    else
      console.log "returning null for '#{k}'"
      null

  
  sticker_prefix_pattern: /^##/
  sticker_prefix: '##'


 
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


that = this
@AppCntl = ($scope, $location, $log, $rootScope, 
  userDataSource, runtime,
  stubDataSvc, evernoteSvc
  ) ->

  # REFACTOR

  that.appModule.env = (newEnv) ->
    if newEnv == 'dev'
      userDataSource.impl = stubDataSvc
    else
      userDataSource.impl = evernoteSvc

    # all state refreshes.
    userDataSource.init()
    $scope.update()

  $rootScope.handleError = (e) ->
    $log.error e

    $rootScope.msg = "error: #{e}"
    $rootScope.error = e



  #### controller actions


  ## stickering

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
      $rootScope.handleError error

  $scope.addSticker = (sticker) -> 
    $scope.page.addSticker sticker
    userDataSource.persist 'page', $scope.page

  $scope.removeSticker = (sticker) ->
    $scope.page.removeSticker sticker
    userDataSource.persist 'page', $scope.page

    # TODO decouple the writes from the user interaction, coalecse and schedule.

  
  ## sticker creation

  $scope.createNewSticker = ->
    $scope.newSticker.name = UserPrefs.sticker_prefix + $scope.newSticker.name unless $scope.newSticker.name.match UserPrefs.sticker_prefix_pattern


    $log.info {msg: "new sticker", sticker:$scope.newSticker}

    # save the new sticker. FIXME
    # userDataSource.persist 'sticker', $scope.newSticker, (newSticker) ->
    #   $scope.stickers.push newSticker
    #   $scope.$apply()
    
    $scope.stickers.push $scope.newSticker
    $scope.newSticker = null

    # TODO error case

    # $scope.fetchStickers()
    # FIXME get delta of stickers


  ## sticker ordering

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


  ## data

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

    return null


  ## workflow

  $scope.login = ->
    # save the location so the oauth module can redirect back.
    localStorage.setItem "oauth_success_redirect_path", location.href

    $location.path "/login"


  ## view

  $scope.showPageDetails = ->
    ! runtime.hasRealPageContext()

  $scope.highlight = (sticker) ->
    $scope.highlightedSticker = sticker
  
  $scope.isHighlighted = (sticker) ->
    $scope.highlightedSticker == sticker

  $scope.colours = [
    {
      name: 'yellow'
    }
    {
      name: 'red'
    }
    {
      name: 'black'
    }
  ]


  ## sticker editing

  $scope.editSticker = (sticker) ->
    $scope.editedSticker = that.clone sticker

  $scope.finishEditingSticker =  ->
    oldSticker = $scope.stickers.filter( (sticker) -> sticker.id == $scope.editedSticker.id )[0]

    # save the changed data.
    userDataSource.updateSticker($scope.editedSticker)
    .then ->
      #  replace the sticker in the collection with editedSticker.
      i = $scope.stickers.indexOf oldSticker
      $scope.stickers[i] = $scope.editedSticker

      $scope.editedSticker = null
    .then null, (error) ->
      $rootScope.handleError error

  $scope.cancelEditingSticker = ->
    $scope.editedSticker = null


  #### doit

  try 
    $rootScope.msg = "Test msg."

    that.appModule.env 'production'
  catch e
    $rootScope.handleError e

    # do the login thing.
    # $scope.login()

    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  

## REFACTOR
 
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
@clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime()) 

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags) 

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance
