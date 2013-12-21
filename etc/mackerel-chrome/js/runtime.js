// Generated by CoffeeScript 1.6.2
(function() {
  this.appModule.factory('runtime', function($log) {
    return {
      pageForUrl: function(url, callback) {
        var d;

        d = Q.defer();
        if (typeof chrome !== "undefined" && chrome !== null ? chrome.extension : void 0) {
          this.pageForUrl_chrome(url, function(page) {
            return d.resolve(page);
          });
        } else {
          $log.info("not running as chrome extension");
          url || (url = 'http://out-of-chrome-stub-url');
          d.resolve({
            url: url,
            title: 'stub url title'
          });
        }
        return d.promise;
      },
      capturePageThumbnail: function() {
        var _this = this;

        if (chrome.extension) {
          return this.capturePageThumbnail_chrome();
        } else {
          return Q.fcall(function() {
            console.log("returning a stub image for the page.");
            return "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBY";
          });
        }
      },
      hasRealPageContext: function() {
        if (chrome.extension) {
          return true;
        } else {
          return false;
        }
      },
      sendMsg: function(msgType, params, callback) {
        if (chrome.extension) {
          return this.sendMsg_chrome(msgType, params, callback);
        } else {
          return $log.info({
            params: params,
            callback: callback
          });
        }
      },
      onMsg: function(msgType, callback) {
        if (chrome.extension) {
          return this.onMsg_chrome(msgType, callback);
        } else {
          return $log.info({
            msgType: msgType,
            callback: callback
          });
        }
      },
      pageForUrl_chrome: function(url, callback) {
        $log.info("initializing chrome extension environment");
        return chrome.windows.getCurrent({}, function(chromeWindow) {
          var _this = this;

          return chrome.tabs.query({
            windowId: chromeWindow.id,
            active: true
          }, function(tabs) {
            $log.info(tabs);
            return callback(tabs[0]);
          });
        });
      },
      capturePageThumbnail_chrome: function() {
        var d;

        d = Q.defer();
        chrome.tabs.captureVisibleTab(null, null, function(dataUrl) {
          return d.resolve(dataUrl);
        });
        return d.promise;
      },
      sendMsg_chrome: function(msgType, params, callback) {
        params || (params = {});
        params.msgType = msgType;
        return chrome.runtime.sendMessage(null, params, callback);
      },
      onMsg_chrome: function(msgType, callback) {
        return chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
          if (request.msgType === msgType) {
            return callback(request, sender, sendResponse);
          } else {
            return $log.info("" + this + " got a message of type " + request.msgType + " and will ignore.");
          }
        });
      }
    };
  });

}).call(this);