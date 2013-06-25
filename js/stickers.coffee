that = this
app = appModule

angular.module( 'appModule' )
  .controller 'StickersCntl',
    ($scope, userPrefs, runtime) ->

      #### controller actions


      ## stickering

      $scope.toggleSticker = (sticker) ->
        doit = ->
          $rootScope.msg = "Saving..."

          unless $scope.page.hasSticker sticker
            $scope.addSticker sticker
          else
            $scope.removeSticker sticker

        doit()
        .then (result) ->
          $rootScope.msg = "Saved."
          $rootScope.$apply()

        .fail (error) ->
          $rootScope.handleError error

      $scope.addSticker = (sticker) -> 
        $scope.page.addSticker sticker
        that.appModule.userDataSource.persist 'page', $scope.page

      $scope.removeSticker = (sticker) ->
        $scope.page.removeSticker sticker
        that.appModule.userDataSource.persist 'page', $scope.page

        # TODO decouple the writes from the user interaction, coalecse and schedule.

      
      ## sticker creation

      $scope.createNewSticker = ->
        newSticker = $scope.newSticker
        newSticker.name = $scope.prefixedName newSticker.name

        that.appModule.userDataSource.createSticker(newSticker)
        .then (savedSticker)->
          $log.info {msg: "new sticker", sticker:savedSticker}

          # save the new sticker. FIXME
          # that.appModule.userDataSource.persist 'sticker', $scope.savedSticker, (savedSticker) ->
          #   $scope.stickers.push savedSticker
          #   $scope.$apply()
          
          $scope.stickers.push savedSticker
          $scope.newSticker = null
          $scope.$apply()

          # $scope.fetchStickers()
          # FIXME get delta of stickers
        .fail (err) ->
          $rootScope.handleError err
        

      ## sticker ordering

      $scope.sortableOptions =
        stop: (e, ui)->
          $log.info "drag-drop finished."
          $scope.saveStickerOrder()

      $scope.saveStickerOrder = ->
        # persist the sticker order list.
        that.UserPrefs.update 'stickerOrder',
          $scope.stickers.map (sticker)-> sticker.name

      $scope.orderedStickers = (stickers)->
        # apply the sticker order list.
        stickerOrder = that.UserPrefs.get 'stickerOrder'
        stickerOrder = [] if ! stickerOrder

        orderedStickers = stickerOrder.map (name) ->
          stickers.filter((sticker) -> sticker.name == name)[0]
        orderedStickers = _.without orderedStickers, undefined

        # add stickers not found in order list at the end.
        stickers.map (sticker) ->
          orderedStickers.push sticker unless _.contains orderedStickers, sticker

        orderedStickers


      ## data

      $scope.fetchPage = ->

        url = if $scope.page 
            $scope.page.url 
          else
            window.location.href

        runtime.pageForUrl( url )
        .then (pageSpec)->
          that.appModule.userDataSource.fetchPage pageSpec

        .then (page) ->
          $scope.page = page
          $scope.$apply()

          # chrome.pageCapture.saveAsMHTML( { tabId: page.id } )
          # .then (mhtmlData) ->
          #   page.pageContent = mhtmlData
            # $log.info { msg: " got the visual representation.", mhtml:mhtmlData }

          runtime.capturePageThumbnail(page)

        .then (dataUrl) ->
          $log.info { msg: " got the visual representation.", dataUrl }

          $scope.page.thumbnailUrl = dataUrl
          $scope.$apply()


      $scope.fetchStickers = (page)->    
        that.appModule.userDataSource.fetchStickers( null)
        .then (stickers) ->
          orderedStickers = $scope.orderedStickers stickers
          orderedStickers = $scope.colouredStickers orderedStickers

          $scope.stickers = orderedStickers

          $scope.$apply()

      $scope.update = ->
        $rootScope.msg = "Fetching data..."
        $rootScope.$apply()

        Q.all([ 
          $scope.fetchPage(), 
          $scope.fetchStickers()
        ])
        .then ->
          $rootScope.msg = ""
          $rootScope.$apply()
        

      ## view

      $scope.showPageDetails = ->
        ! runtime.hasRealPageContext()

      $scope.highlight = (sticker) ->
        $scope.highlightedSticker = sticker
      
      $scope.isHighlighted = (sticker) ->
        $scope.highlightedSticker == sticker


      ## sticker editing

      $scope.colours = [
        {
          name: 'yellow'
          code: '#eeed50'
        }
        {
          name: 'red'
          code: '#ef4e4e'
        }
        {
          name: 'violet'
          code: '#85648c'
        }
        {
          name: 'pink'
          code: '#deadb4'
        }
        {
          name: 'green'
          code: '#95a666'
        }
        {
          name: 'khaki'
          code: '#4f5549'
        }
        {
          name: 'blue'
          code: '#82b2c6'
        }
        {
          name: 'navy'
          code: '#3a5579'
        }
      ]

      $scope.editSticker = (sticker) ->
        $scope.editedSticker = that.clone sticker

      $scope.finishEditingSticker =  ->
        oldSticker = $scope.stickers.filter( (sticker) -> sticker.id == $scope.editedSticker.id )[0]

        $scope.editedSticker.name = $scope.prefixedName $scope.editedSticker.name
        # save the changed data.
        that.appModule.userDataSource.updateSticker($scope.editedSticker)
        .then ->
          # replace the sticker in the collection with editedSticker.
          i = $scope.stickers.indexOf oldSticker
          $scope.stickers[i] = $scope.editedSticker

          # save collection properties.
          $scope.saveStickerOrder()
          $scope.saveStickerColours()

          $scope.editedSticker = null

          $scope.$apply()
          
        .fail (error) ->
          $rootScope.handleError error


      $scope.cancelEditingSticker = ->
        $scope.editedSticker = null

      $scope.saveStickerColours = ->
        colours = $scope.stickers.map (e) -> 
          name: e.name
          colour: e.colour
        
        UserPrefs.update 'stickerColours', colours


      $scope.colouredStickers = (stickers) ->

        colours = UserPrefs.get 'stickerColours'
        if colours
          remainingColours = colours
          stickers.map (sticker) ->
            colourSpec = remainingColours.filter((e) -> e.name == sticker.name)[0]
            sticker.colour = colourSpec.colour if colourSpec

            remainingColours = _.reject remainingColours, (e) -> e == colourSpec
          
        stickers
        

      $scope.prefixedName = (name) ->
        if name.match UserPrefs.sticker_prefix_pattern
          name
        else
          UserPrefs.sticker_prefix + name 
      

      # expose controller
      app.stickersC = 
        update: ->
          $scope.update()


      #### doit
      # app.env that.UserPrefs.get('env'), $scope
      userPrefs.apply()


## REFACTOR
 
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
@clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime()) 

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags) 

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance
