@appModule.factory 'runtime', ($log)->

  pageForUrl: (url, callback)->

    d = Q.defer()

    # init chrome-specific
    if chrome?.extension
      @pageForUrl_chrome url, (page) ->
        d.resolve page
          
    else

      $log.info "not running as chrome extension"
      url ||= 'http://out-of-chrome-stub-url'

      d.resolve
        url: url
        title: 'stub url title'

    d.promise

  capturePageThumbnail: ->
    if chrome.extension
      @capturePageThumbnail_chrome()
    else
      Q.fcall =>
        console.log "returning a stub image for the page."

        return "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBY"

  hasRealPageContext: ->
    if chrome.extension
      true
    else
      false

  sendMsg: (msgType, params, callback)->
    if chrome.extension
      @sendMsg_chrome msgType, params, callback
    else
      $log.info { params, callback }

  onMsg: (msgType, callback)->
    if chrome.extension
      @onMsg_chrome msgType, callback
    else
      $log.info { msgType, callback }


  ## chrome extension environment

  pageForUrl_chrome: (url, callback) ->
    $log.info "initializing chrome extension environment"
    chrome.windows.getCurrent {}, (chromeWindow) -> 
      chrome.tabs.query {windowId: chromeWindow.id, active: true}, (tabs) =>
        $log.info tabs
        callback tabs[0]
  
  capturePageThumbnail_chrome: ->
    d = Q.defer()

    chrome.tabs.captureVisibleTab null, null, (dataUrl) ->
      d.resolve dataUrl
      
    d.promise

  # callback sig:
  sendMsg_chrome: (msgType, params, callback)->
    params ||= {}
    params.msgType = msgType
    chrome.runtime.sendMessage null, params, callback
  # callback sig: 
  onMsg_chrome: (msgType, callback) ->
    chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
      if request.msgType == msgType
        callback request, sender, sendResponse
      else
        $log.info "#{this} got a message of type #{request.msgType} and will ignore."
    
    
