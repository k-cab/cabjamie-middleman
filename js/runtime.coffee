@appModule.factory 'runtime', ($log)->

  pageForUrl: (url, callback)->
    # init chrome-specific
    if chrome.extension
      @pageForUrl_chrome url, callback
    else
      $log.info "not running as chrome extension"
      url ||= 'http://out-of-chrome-stub-url' 
      callback
        url: url
        title: 'stub url title'

  capturePageThumbnail: ->
    if chrome.extension
      @capturePageThumbnail_chrome()
    else
      new RSVP.Promise (resolve, reject) =>
        console.log "returning a stub image for the page."

        resolve "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBY"

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
    promise = new RSVP.Promise (resolve, reject) =>
      try
        chrome.tabs.captureVisibleTab null, null, (dataUrl) ->
          resolve dataUrl
      catch e
        reject e
      
  
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
    
    
