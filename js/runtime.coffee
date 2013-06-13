@appModule.factory 'runtime', ($log)->

  withCurrentResource: (callback)->
    # init chrome-specific
    if chrome.extension
      @withCurrentResource_chrome callback
    else
      $log.info "not running as chrome extension"
      callback
        url: 'http://out-of-chrome-stub-url'
        title: 'stub url title'

  captureTab: ->
    if chrome.extension
      @captureTab_chrome()
    else
      new RSVP.Promise (resolve, reject) =>
        resolve "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBY"

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

  withCurrentResource_chrome: (callback) ->
    $log.info "initializing chrome extension environment"
    chrome.windows.getCurrent {}, (chromeWindow) -> 
      chrome.tabs.query {windowId: chromeWindow.id, active: true}, (tabs) =>
        $log.info tabs
        callback tabs[0]
  
  captureTab_chrome: ->
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
    
    
