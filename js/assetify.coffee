"use strict"
angular.module("appModule").directive "bblAssetify", ->
  # template: "<div></div>"
  restrict: "A"
  link: postLink = (scope, element, attrs) ->
    scrubbedText = element.text().toLowerCase()

    # add a css class named after body text content.
    cssClass = attrs.class
    cssClass ||= ""
    attrs.$set 'class', cssClass + " " + scrubbedText

    # PLAN for a tags, add href 
    # eg <a bblAssetify>what's new</a>
    # to:
    # <a class="whatsnew" href="./whatsnew">what's new</button>
