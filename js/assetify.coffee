"use strict"
angular.module("appModule").directive "bblAssetify", ->
  # template: "<div></div>"
  restrict: "A"
  link: postLink = (scope, element, attrs) ->
    scrubbedText = element.text().toLowerCase().trim()

    # add styling for background-image to avoid the hassle of referencing assets.
    assetUrl = "assets/#{scrubbedText}.png"
    styleVal = attrs.style
    styleText = """
      background-image: url("#{assetUrl}");
    """
    # TODO if asset available, additionally don't display the text.

    attrs.$set 'style', (styleVal && styleVal + " " || "") + styleText
    

    # add a css class named after body text content.
    classVal = attrs.class
    attrs.$set 'class', (classVal && classVal + " " || "") + scrubbedText

    # PLAN for a tags, add href 
    # eg <a bblAssetify>what's new</a>
    # to:
    # <a class="whatsnew" href="./whatsnew">what's new</button>
