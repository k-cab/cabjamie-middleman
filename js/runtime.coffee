@appModule.factory 'runtime', ($log)->

  withCurrentResource: (callback)->
    # init chrome-specific
    if chrome.extension
      $log.info "initializing chrome extension environment"
      chrome.tabs.query {active: true}, (tabs) =>
        url = tabs[0].url
        $log.info {page: this, url: url}
        callback url
    else
      $log.info "not running as chrome extension"
      url = 'out-of-chrome-stub-url'
      callback url


