## Prerequisites

* (testing) An account with the Evernote sandbox instance: create an account for testing at https://sandbox.evernote.com .

* 


## Known issues

* we need to sync this from bug tracker.


## Build

* there shouldn't be any.


## Install


* Open the Chrome extensions page: Window > Extensions in the app menu.

* Enable developer mode by selecting the checkbox.

* Click on the button named 'Load unpacked extension...'

* Select the folder 'builds/mackerel-chrome', under this folder, in the file selection dialog.


## Reload

* Once a new build is deployed, reload the extension by selecting 'Reload' under the extension in the list, if you don't see latest changes.


## Notes on this folder

* You should be reading this from the bbl-middleman/source/mackerel-chrome folder, unless you're investigating files in the build, or examining the installed extension. This means you have access to the Dropbox folder for the team, or the git repository. Well done for coming this far!

* The files under source/ are the source files we work with to get a product out. All of us will directly work with these files, resulting in direct changes that our users will see. I've taken a lot of time and effort to set this up, and I think it will dramatically increase our production efficiency. It will be cool when this starts to work well.

* It will greatly aid your understanding if you open the Dropbox/bigbearlabs/bbl-middleman/ folder in your file browser and browse through to see. In fact, do this now, I'm making it a non-option.

* bbl-middleman/ is a unified folder that will eventually contain all of our site material, and the extension we built. it is named after the static site builder software that forms the framework.

* we generally have extremely tidy files that should be very easy to work with, for content. have a look at tagyeti/index.html.haml for example. 

* for now, we have webbuddy/, onehour/, blog/ as work-in-progress. also, / is work-in-progress, but will have to be completed, as this represents bigbearlabs.com that I'd like to get ready by release.

* The general workflow is to add / edit files for content and work directly with a local 'server', then the change moves up the staging environment automatically, then you check and release to production if you are happy with it. This means we can be aggressive on making changes, and see results fast, and you're assisted in your responsibility to integrate it in the product.

* Everything, including a version of our product, will be served on the web. At the moment, the extension doesn't work properly, but we will make that happen as then we can use it from e.g. our phones or iPads, as well as desktop Safari etc. But it's not working in production mode, so there's a dev mode that just shows you a UI for esp. designers to directly work on the product. 

* If you've made images, put them at the right folder, e.g. sources/mackerel-chrome/assets/, or sources/images/tagyeti/marketing.png. Images for the sites are in sources/images/. Images for the product are in the product's assets/ folder.

* If you've made content, put them at the right folder. Generally, new directories and files for websites will work. For e.g. extensions, they need to have placeholders provisioned first.

* Feel free to add your own personal folders for work-in-progress items for image source files, draft writings etc, but please remember you should organise things according to convention. Generally, choose the stuff you want to publish, and directly publish, as you can always change it if you think it should get better.

* As this process works, I am planning to literally turn off any day-to-day concerns on whether something's showing up on the app, and make the automated workflow deal with integrating your work on all our components. The site, the extension, the web version etc. should all be considered products, and you'll be directly shaping them.

* This is going to take a bit of time to get working smoothly. So please all be patient, and trust me when I say this will really be worth it. I'm planning to use this as a publicity material at some point. 
