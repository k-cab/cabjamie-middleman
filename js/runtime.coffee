@appModule.factory 'runtime', ($log)->

  withCurrentResource: (callback)->
    # init chrome-specific
    if chrome.extension
      $log.info "initializing chrome extension environment"
      chrome.windows.getCurrent {}, (chromeWindow) -> 
        chrome.tabs.query {windowId: chromeWindow.id, active: true}, (tabs) =>
          $log.info tabs
          url = tabs[0].url
          $log.info {msg: "chrome env", url: url}
          callback url
    else
      $log.info "not running as chrome extension"
      url = 'out-of-chrome-stub-url'
      callback url


