
# DEV
Q.longStackSupport = true

@appModule = angular.module "appModule", ['ui', 'ngResource'], ($routeProvider, $locationProvider) ->
  $routeProvider

  .when "/",
    templateUrl: "templates/stickers.html"
    controller: 'AppCntl'

  .when "/intro",
    templateUrl: "templates/intro.html"
    controller: 'IntroCntl'

  .when "/login",
    templateUrl: "templates/oauth.html"
    controller: 'AuthenticationCntl'

  .when "/logout",
    templateUrl: "templates/authentication.html"
    controller: 'AuthenticationCntl'

  .when "/stickers",
    templateUrl: "templates/stickers.html"
    controller: 'StickersCntl'

  .otherwise
    redirectTo: "/"

.config ($compileProvider)->
  # prevent url's being prefixed with 'unsafe:'
  # REFACTOR to runtime
  $compileProvider.urlSanitizationWhitelist(/^\s*(https?|chrome-extension):/) 


@appModule.controller 'IntroCntl',
($scope, $log, $location, $resource
userPrefs) ->
  # stub
  $scope.contentSequence = [
    {
      number: 1
      imgUrl: -> "assets/intro-#{@number}.png"
      text: 'content to go here.'
      subtext: 'if you need detailed explanation, use this.'
    }
    {
      number: 2
      imgUrl: -> "assets/intro-#{@number}.png"
      text: 'content 2 to go here.'
      subtext: 'if you need detailed explanation, use this.'
    }
  ]
  $scope.contentSequence = $resource('assets/intro.json').query =>
    $log.info { msg: 'fetched intro content', obj: $scope.contentSequence }
    $scope.refreshContent()

  $scope.currentSequenceNumber = 0

  $scope.refreshContent = ->
    # cap the number
    $scope.content = $scope.contentSequence[$scope.currentSequenceNumber]
  

  $scope.next = ->
    $log.info "next"
    $scope.currentSequenceNumber += 1
    $scope.refreshContent()

  $scope.previous = ->
    $log.info "previous"
    $scope.currentSequenceNumber -= 1
    $scope.refreshContent()

  $scope.finishIntro = ->
    userPrefs.setFinishedIntro()
    $location.path '/'

  ## doit
  $scope.refreshContent()
  

# no longer relevant after routing changes.
@AppCntl = ($scope, $location, $log, $rootScope,
  globalsSvc, userPrefs,
  runtime,
  stubDataSvc, evernoteSvc
  ) ->

  # that.appModule.runtime = runtime

  # that.appModule.stubDataSvc = stubDataSvc
  # that.appModule.evernoteSvc = evernoteSvc
  
  #### doit

  if userPrefs.needsIntro()
    $location.path "/intro"
    return
    
  Q.fcall ->
    # update will set authentication status
    globalsSvc.doit()
    # globalsSvc.update()
  .then ->
    if $rootScope.authentication.loggedIn
      $location.path "/stickers"
    else
      $location.path "/login"

    $rootScope.$apply()

  .done()


    
  # runtime.onMsg 'testType', (args...) ->
  #   console.log "onMsg args: #{args}"
  
  # runtime.sendMsg 'testType', null, (response) ->
  #   console.log "got response: #{response}"
  


