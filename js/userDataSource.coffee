Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

@appModule.factory 'userDataSource', ($log) ->

  fetch: (dataType, params, resultHandler) ->
    # just the sticker type for now.

    # this.fetch_stub dataType, resultHandler
    this.fetch_parse dataType, params, resultHandler


  fetch_stub: (dataType, resultHandler) ->
    results = [
      {
          name: "stub-sticker-1",
      },
      {
          name: "stub-sticker-2",
      },
      {
          name: "stub-sticker-3"
      },
    ]

    resultHandler results

  fetch_parse: (dataType, params, resultHandler) ->
    attrsToProps = (obj, attrs...) ->
      attrs.forEach (attr) ->
        val = obj.get attr
        obj[attr] = val if val
          

    switch dataType
      when 'stickers'
        Sticker = Parse.Object.extend('Sticker')
        query = new Parse.Query(Sticker)

        preprocessResults = ->

      when 'items'
        # TODO address abstraction gap between items and pages.
        Page = Parse.Object.extend('Page')
        query = new Parse.Query(Page) 
        query.equalTo('stickers', params[0])

        preprocessResults = (results) ->
          results.forEach (result) ->

            result.relation('stickers').query().find

              success: (stickers) ->
                stickers.forEach (sticker) -> 
                  attrsToProps sticker, 'name'

                result.stickers = stickers

              error: (error) ->
                $log.error error
                          
      when 'page'
        Page = Parse.Object.extend('Page')
        query = new Parse.Query(Page) 
        query.equalTo('url', params[0])

        preprocessResults = (results) ->
          if results.length > 0
            result = results[0]

            # debugger
            # DUP


            result.relation('stickers').query().find

              success: (stickers) ->
                stickers.forEach (sticker) -> 
                  attrsToProps sticker, 'name'

                result.stickers = stickers

              error: (error) ->
                $log.error error

          else
            result = new Page()
            results.push result

      else
        throw "unknown data type #{dataType}"
   
    query.find
      success: (results) ->
        $log.info "Successfully retrieved " + results.length + " entries."

        preprocessResults results

        # HACK convert the attrs to properties.
        results.forEach (result) -> 
          attrsToProps result, 'name', 'url'
        
        resultHandler results

      error: (error) ->
        $log.info "Error: " + error.code + " " + error.message
        # deferred.notify error
        resultHandler error



  persist: (type, modelObj) ->
    this.persist_parse type, modelObj

  persist_parse: (type, data) ->
    switch type
      when 'page'
        Page = Parse.Object.extend 'Page'
        modelObj = new Page
        properties = [ 'url' ]  # only non-collection properties

        # set up the relation for stickers
        if data.stickers
          $log.info { stickers: data.stickers }
          stickersRelation = modelObj.relation('stickers')
          stickersRelation.add data.stickers

      when 'sticker'
        Sticker = Parse.Object.extend 'Sticker'
        modelObj = new Sticker
        properties = []

    # REFACTOR
    properties.forEach (p) =>
      modelObj.set(p, data[p])

    modelObj.save null,
      success: (theObj) ->
        $log.info "save successful"
      error: (theObj) ->
        $log.info "save failed"


