that = this
app = appModule

@stickersCntl = angular.module( 'appModule' )
  .controller 'StickersCntl',
    ($log, $scope, $rootScope, $location
      userPrefs, runtime, globalsSvc) ->

      # expose controller
      app.stickersC = 
        update: ->
          $scope.update()


      $scope.shouldShowMenu = true

      ## quickly dispatch if we can.
      if $location.path().match '/edit'
        $scope.editSticker null  # will probably blow up.

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
          globalsSvc.handleError error

      $scope.addSticker = (sticker) -> 
        $scope.page.addSticker sticker
        app.userDataSource.persist 'page', $scope.page

      $scope.removeSticker = (sticker) ->
        $scope.page.removeSticker sticker
        app.userDataSource.persist 'page', $scope.page

        # TODO decouple the writes from the user interaction, coalecse and schedule.

      
      ## sticker creation

      $scope.startCreateSticker = ->
        $scope.newSticker = new Sticker
          name: 'Noname'

        $scope.editCallback = $scope.finishCreatingSticker

        $scope.editSticker $scope.newSticker

      # this has to be called for a clean save / insertion in view model. so pass in as 
      # completion handler to editsticker. TODO 
      $scope.finishCreatingSticker = ->
        # FIXME encapsulation break - $scope.editedSticker due to last-minute rewiring

        $scope.newSticker = $scope.editedSticker

        newSticker = $scope.newSticker
        newSticker.name = $scope.prefixedName newSticker.name

        app.userDataSource.createSticker(newSticker)
        .then (savedSticker)->
          $log.info {msg: "new sticker", sticker:savedSticker}

          # save the new sticker. FIXME
          # app.userDataSource.persist 'sticker', $scope.savedSticker, (savedSticker) ->
          #   $scope.stickers.push savedSticker
          #   $scope.$apply()
          
          $scope.stickers.push savedSticker
          
          $scope.newSticker = null
          $scope.editedSticker = null

          $scope.$apply()

          # $scope.fetchStickers()
          # FIXME get delta of stickers
        .fail (err) ->
          err.userMessage = "Sorry, a sticker named '#{newSticker.name}' already exists."
          globalsSvc.handleError err
        

      ## sticker ordering

      $scope.sortableOptions =
        stop: (e, ui)->
          $log.info "drag-drop finished."
          $scope.saveStickerOrder()

      $scope.saveStickerOrder = ->
        # persist the sticker order list.
        userPrefs.set 'stickerOrder',
          $scope.stickers.map (sticker)-> sticker.name

      $scope.orderedStickers = (stickers)->
        # apply the sticker order list.
        stickerOrder = userPrefs.get 'stickerOrder'
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
          app.userDataSource.fetchPage pageSpec

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
        app.userDataSource.fetchStickers( null)
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
        if $scope.editCallback
          $scope.editCallback()
          return

        oldSticker = $scope.stickers.filter( (sticker) -> sticker.id == $scope.editedSticker.id )[0]

        $scope.editedSticker.name = $scope.prefixedName $scope.editedSticker.name
        # save the changed data.
        app.userDataSource.updateSticker($scope.editedSticker)
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
          globalsSvc.handleError error


      $scope.cancelEditingSticker = ->
        $scope.editedSticker = null

      $scope.saveStickerColours = ->
        colours = $scope.stickers.map (e) -> 
          name: e.name
          colour: e.colour
        
        userPrefs.set 'stickerColours', colours


      $scope.colouredStickers = (stickers) ->

        colours = userPrefs.get 'stickerColours'
        if colours
          remainingColours = colours
          stickers.map (sticker) ->
            colourSpec = remainingColours.filter((e) -> e.name == sticker.name)[0]
            sticker.colour = colourSpec.colour if colourSpec

            remainingColours = _.reject remainingColours, (e) -> e == colourSpec
          
        stickers
        

      $scope.prefixedName = (name) ->
        if name.match userPrefs.sticker_prefix_pattern
          name
        else
          userPrefs.sticker_prefix + name 
      

      #### doit

      # app.env userPrefs.get('env'), $scope

      # userPrefs.apply()

      Q.fcall ->
        globalsSvc.doit()
      .fail (e) ->
        globalsSvc.handleError e
      .done()

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
