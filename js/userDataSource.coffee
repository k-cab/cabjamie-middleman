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
    switch dataType
      when 'stickers'
        Sticker = Parse.Object.extend('Sticker')
        query = new Parse.Query(Sticker)

      when 'items'
        # TODO address abstraction gap between items and pages.
        Page = Parse.Object.extend('Page')
        query = new Parse.Query(Page) 
        query.equalTo('stickers', params[0])

      when 'page'
        Page = Parse.Object.extend('Page')
        query = new Parse.Query(Page) 
        query.equalTo('url', params[0])

      else
        throw "unknown data type #{dataType}"
   
    query.find
      success: (results) ->
        $log.info "Successfully retrieved " + results.length + " entries."
        results.forEach (result) ->
          # HACK convert the attrs to properties.
          [ 'name', 'url', 'stickers' ].forEach (attr) ->
            result[attr] = result.get attr
        
        resultHandler results
      error: (error) ->
        $log.info "Error: " + error.code + " " + error.message
        # deferred.notify error
        resultHandler error


  persist: (modelObj) ->
    this.persist_parse modelObj

  persist_parse: (modelObj) ->
    switch modelObj.className
      when 'Page'
        properties = [ 'url' ]  # only non-collection properties

        # set up the relation for stickers
        if modelObj.stickers
          $log.info { stickers: modelObj.stickers }
          stickersRelation = modelObj.relation('stickers')
          stickersRelation.add modelObj.stickers
      #...    

    # REFACTOR
    properties.forEach (p) =>
      modelObj.set(p, modelObj[p])

    modelObj.save null,
      success: (theObj) ->
        $log.info "save successful"
      error: (theObj) ->
        $log.info "save failed"


  
