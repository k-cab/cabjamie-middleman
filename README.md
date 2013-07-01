# bbl-middleman


## Installing
```
bbl-middleman$ sudo gem install middleman
bbl-middleman$ bundle install
```
Install LiveReload Chrome extension. https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei


## Quick start
```
bbl-middleman$ bundle exec middleman server
```
Enable the LiveReload extension.


## Known issues

### dev
- coffeescript compilation still processed manually, due to middleman dependency on coffee-script-source 1.3.3
- livereload gem disabled due to undesirable swfobject insertion - use browser extension.

