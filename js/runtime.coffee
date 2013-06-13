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
      throw "unimplemented out of chrome"


  sendMsg: (params, callback)->
    if chrome.extension
      @sendMsg_chrome params, callback
    else
      $log.info { params, callback }

  onMsg: (params, callback)->
    if chrome.extension
      @onMsg_chrome params, callback
    else
      $log.info { params, callback }


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
  sendMsg_chrome: (params, callback)->
    chrome.extension.sendMessage params, callback

  # callback sig: 
  onMsg_chrome: (callback) ->
    chrome.extension.onMessage.addListener callback
