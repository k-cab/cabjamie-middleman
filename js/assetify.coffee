"use strict"
angular.module("angularGenApp").directive "bblAssetify", ->
  template: "<div></div>"
  restrict: "E"
  link: postLink = (scope, element, attrs) ->
    element.text "this is the bblAssetify directive"

