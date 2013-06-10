
if chrome.webRequest
  chrome.webRequest.onHeadersReceived.addListener ((info) ->
    headers = info.responseHeaders
    i = headers.length - 1

    while i >= 0
      header = headers[i].name.toLowerCase()
      headers.splice i, 1  if header is "x-frame-options" or header is "frame-options" # Remove header
      --i
    responseHeaders: headers
  ),
    urls: ["*://*/*"] # Pattern to match all http(s) pages
    types: ["main_frame", "sub_frame"]
  , ["blocking", "responseHeaders"]
