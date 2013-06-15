@appModule = angular.module("appModule", [ ], ($routeProvider, $locationProvider) ->
  $routeProvider
  .when "/stickers",
    templateUrl: "templates/stickers.html"
    controller: @AppCntl
  .when "/login",
    templateUrl: "templates/oauth.html"
  .otherwise
    redirectTo: "/stickers"
)

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
    $scope.newSticker.name = "##" + $scope.newSticker.name unless $scope.newSticker.name.match /^##/


    $log.info {msg: "new sticker", sticker:$scope.newSticker}

    # userDataSource.persist 'sticker', $scope.newSticker, (newSticker) ->
    #   $scope.stickers.push newSticker
    #   $scope.$apply()
    
    $scope.stickers.push $scope.newSticker
    $scope.newSticker = null

    # TODO error case

    # $scope.fetchStickers()
    # FIXME get delta of stickers


  $scope.fetchPage = ->

    promise = new RSVP.Promise (resolve, reject) ->
      runtime.withCurrentResource (tab)->
        userDataSource.fetch 'page', tab, (pages) ->
          try
            page = pages[0]
            page.title = tab.title
            $scope.page = page
            

            # chrome.pageCapture.saveAsMHTML( { tabId: tab.id } )
            # .then (mhtmlData) ->
            #   page.pageContent = mhtmlData
              # $log.info { msg: " got the visual representation.", mhtml:mhtmlData }

            runtime.captureTab(tab)
            .then (dataUrl) ->
              $log.info { msg: " got the visual representation.", dataUrl }

              $scope.page.thumbnailUrl = dataUrl

              resolve $scope.page

          catch e
            reject e

  $scope.fetchStickers = (page)->    

    promise = new RSVP.Promise (resolve, reject) ->
      userDataSource.fetch 'stickers', [], (stickers) ->
        try

          $scope.stickers = stickers

          # this seems redundant now, but sweep for regressions
          # $scope.$apply()

          resolve stickers
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

  localStorage.setItem "oauth_success_redirect_path", location.href
  try 
    $rootScope.msg = "Test msg."

    userDataSource.init()
    $scope.update()
  catch e
    $rootScope.msg = error

    # do the login thing.
    $scope.login()

    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  
  