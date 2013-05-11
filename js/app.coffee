appModule = angular.module("appModule", [], ($routeProvider, $locationProvider) ->
  $routeProvider.when "/",
    templateUrl: "templates/index.html"
    controller: AppCntl
)

Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm");

@AppCntl = ($scope) ->
  $scope.page = new Page()
  if chrome.extension
    console.log "initializing chrome extension environment"
    chrome.tabs.query {active: true}, (tabs) =>
      url = tabs[0].url
      $scope.page.url = url
      console.log({page: this, url: url})


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


@Page = Parse.Object.extend "Page",
  url: 'stub-url'

  addSticker: (sticker) ->
    console.log
      obj: sticker
      msg: "add sticker to #{this.url}"

    this.persist()

  persist: ->
    this.persist_parse [ 'url' ]

  persist_parse: (properties) ->
    properties.forEach (p) =>
      this.set(p, this[p])

      this.save null,
        success: (page) ->
          console.log "save successful"
        error: (page) ->
          console.log "save failed"


