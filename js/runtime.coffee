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
        callback
          url: tabs[0].url
          title: tabs[0].title
  
  # callback sig:
  sendMsg_chrome: (params, callback)->
    chrome.extension.sendMessage params, callback

  # callback sig: 
  onMsg_chrome: (callback) ->
    chrome.extension.onMessage.addListener callback
