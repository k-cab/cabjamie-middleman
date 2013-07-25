_ = require('lodash')
promisify = require('when-promisify')

Q = require('q')
Q.longStackSupport = true

atob = require 'atob'

crypto = require('crypto')

Parse = require('parse').Parse
Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

Credentials = Parse.Object.extend 'Credentials'

Types = require('./evernode').Types;


store  =
  getCredentials: (vendorId, username) ->
    unless vendorId && username
      throw "null params for store query."

    q = new Parse.Query Credentials
    q.equalTo 'vendorId', vendorId
    q.equalTo 'username', username

    q.find()
    # TODO ensure we order results.


  setCredentials: (vendorId, username, credentials) ->
    new Credentials().save {
      vendorId
      username
      credentials
    }

evernote = null  # going to get the obj from the app.

module.exports = obj =

  setup: (app)=> 
    evernote = app.evernote

    app.store = store

    # e.g. building a rest api
    # app.post '/mackerel/tags/:guid', (req, res) ->
    #   return res.send tag, 200


    # INSECURE
    app.all '/authentication/details', (req, res)=>
      details = {}
      obj.sendData details, res


    # OPTIONS necessary for successful post
    handleOptions = (req, res)->
      res.header "Access-Control-Allow-Headers", "Content-Type, x-username"
      obj.sendData null, res

    app.options '/mackerel/page', (req, res) ->
      handleOptions req, res
    app.options '/mackerel/stickers', (req, res) ->
      handleOptions req, res


  # page

    app.get '/mackerel/page', (req, res) =>
      stub_page = 
        url: 'http://stub-url'
        stickers: [
          {
            name: "stub-sticker-3"
          }
        ]

      obj.serveEvernoteRequest req, res, (userInfo)->

        params =
          url: req.query.url
          title: req.query.title

        obj.fetchPages( userInfo, params)
        .then (pages)->
          page = pages[0]
          unless page
            page = params
            page.stickers = []

          obj.sendData page, res

        
    app.post '/mackerel/page', (req, res) =>

      obj.serveEvernoteRequest req, res, (userInfo)->
        thumbnailUrl = req.body.thumbnailUrl

        thumbnail = obj.urlToThumbnail thumbnailUrl

        obj.savePage( userInfo, {
            title: req.body.title
            tagGuids: req.body.stickers.map( (e) ->
                # if e.name
                #   e.name
                # else
                #   console.error "didn't receive name for tag #{e.id}"
                  e.id
              )
              # .concat 'Mackerel'
            url: req.body.url
            thumbnailData: thumbnail.data
            thumbnailMd5Hex: req.body.thumbnailMd5Hex
            thumbnailDataB64: thumbnail.dataB64
          })
        .then (note) ->
          obj.sendData 
            guid: note.guid
          , res

          obj.mergeDuplicates userInfo,  
            url: req.body.url

  # stickers

    app.get '/mackerel/stickers', (req, res) =>
      stub_stickers = [
        {
          id: 1
          name: "stub-sticker-1",
        }
        {
          id: 2
          name: "stub-sticker-2",
        }
        {
          id: 3
          name: "stub-sticker-3"
        }
        {
          id: 4
          name: "##honeymoon"
        }
        {
          id: 5
          name: "##longnameherelsdkfjdklsj"
        }
        {
          id: 6
          name: "stub-sticker-6"
        }
        {
          id: 7
          name: "stub-sticker-7"
        }
        {
          id: 8
          name: "stub-sticker-8"
        }
      ]

      # based on everest.js
      obj.serveEvernoteRequest req, res, (userInfo)->
        obj.fetchStickers( userInfo)
        .then (stickers) ->
          obj.sendData stickers, res


    app.post '/mackerel/stickers', (req, res) =>
      # create or update evernote tag.
      obj.serveEvernoteRequest req, res, (userInfo)->
        Q.fcall ->
          name = req.body.name
          id = req.body.id
          if id
            obj.updateSticker userInfo, {
              guid: id
              name
            }
          else
            obj.findSticker( userInfo, { name })
            .then (sticker) ->
              if sticker
                obj.updateSticker( userInfo, { guid: sticker.guid, name })
              else
                obj.createSticker userInfo, { name }

        .then (sticker) ->
          if typeof(sticker) == 'object'
            resultData = sticker
            
          obj.sendData resultData, res




  # private api layer

    app.get '/mackerel/notes', (req, res) =>
      obj.serveEvernoteRequest req, res, (userInfo)->
        url = req.query.url
        words = "sourceURL:#{url}"
        offset = 0
        count = 10  # CASE handle duplicate notes
        sortOrder = 'UPDATED'
        ascending = false

        evernote.findNotes userInfo,  words, { offset:offset, count:count, sortOrder:sortOrder, ascending:ascending }, (err, noteList)->
          if (err)
            obj.sendError res, err
            return
          else
            return obj.sendData noteList, res


    console.log('mackerel api initialised.')
    


  sendData: (data, res)->
    res.header "Access-Control-Allow-Origin", "*"
    res.send data, 200

  sendError: (res, err) ->
    return res.send err,403 if (err == 'EDAMUserException') 

    return res.send(err,500)
  

  fetchPages: (userInfo, params)->
    d = Q.defer()

    obj.findNotes userInfo,
      url: params.url
    .then (notes) ->
      pages = notes.map (note) ->
        id: note.id
        url: note.attributes.sourceURL
        title: note.title
        stickers: note.tagGuids.map (guid)->
          id: guid

      d.resolve pages

    d.promise
    
  
  savePage: (userInfo, params)->
    d = Q.defer()

    linkToPage = "<a href='#{encodeURI(params.url)}'>'#{params.title}'</a>"

    thumbnail = new Buffer params.thumbnailData

    md5 = crypto.createHash 'md5'
    md5.update thumbnail
    thumbnailMd5Hex = md5.digest 'hex'

    data = new Types.Data()
    data.body = thumbnail
    data.size = thumbnail.length
    data.bodyHash = params.thumbnailDataB64

    resource = new Types.Resource()
    resource.mime = 'image/jpeg'
    resource.data = data

    note =
      title: params.title 
      tagGuids: params.tagGuids

      attributes:
        sourceURL: params.url

      content: """
        <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
        <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;">
          <div>#{linkToPage}</div>
          <en-media type="image/jpeg" hash="#{thumbnailMd5Hex}" width="100%"/>
          <div>Stickers: TODO links to stickers on this page</div>
          <div>Date: #{new Date()}</div>
        </en-note>
        """

      resources: [ resource ]

    evernote.createNote userInfo, note, (err, note) ->
      d.resolve note


    # CASE update the note if necessary.
    # CASE more posts before note fully created.

    d.promise


  fetchStickers: (userInfo)->
    deferred = Q.defer()

    evernote.listTags userInfo, (err, tags) -> 
      if (err) 
        deferred.reject err
      else
        sticker_prefix_pattern = /^##/
        stickers = tags.filter (tag) -> tag.name.match sticker_prefix_pattern

        deferred.resolve stickers.map (sticker) ->
          id: sticker.guid
          name: sticker.name


    deferred.promise


  # only works with the name.
  findSticker: (userInfo, params) ->
    d = Q.defer()

    obj.fetchStickers(userInfo)
    .then (stickers)->
      matches = stickers.filter (sticker) ->
        sticker.name == params.name

      if matches.length > 1
        throw "more than 1 match for #{params}"
      
      d.resolve matches[0]
    
    d.promise
  

  createSticker: (userInfo, params) ->
  
    # if(!req.session.user) return res.send('Unauthenticate',401);
    # if(!req.body) return res.send('Invalid content',400);

    # var tag = req.body;
    # var userInfo = req.session.user;
    
    # evernote.createTag(userInfo, tag, function(err, tag) {
      
    #   if (err) {
    #     if(err == 'EDAMUserException') return res.send(err,403);
    #     return res.send(err,500);
    #   } 

    #   return res.send(tag,200);
    # });

    d = Q.defer()

    tag =
      name: params.name

    evernote.createTag userInfo, tag, (err, tag) ->
      throw err if err
      d.resolve tag
  
    d.promise

  
  updateSticker: (userInfo, params) ->
    # if(!req.session.user) return res.send('Unauthenticate',401);
    # if(!req.body) return res.send('Invalid content',400);
    
    # var tag = req.body;
    # var userInfo = req.session.user;
    
    # tag.guid = req.params.guid;
    
    # evernote.updateTag(userInfo, tag, function(err, tag) {
      
    #   if (err) {
    #     if(err == 'EDAMUserException') return res.send(err,403);
    #     return res.send(err,500);
    #   } 

    #   return res.send(tag,200);
    # });

    d = Q.defer()

    tag =
      guid: params.guid
      name: params.name    

    evernote.updateTag userInfo, tag, (err, tag)->
      throw err if err
      d.resolve tag
  
    d.promise
  

  mergeDuplicates: (userInfo, params) ->
    Q.fcall ->
      if params.notes
        params.notes
      else
        obj.findNotes userInfo, params
    .then (notes) ->
      orderedNotes = _.sortBy notes, (e) -> e.updated
      latestNote = orderedNotes[0]
      # use the tags from the latest note
      tagGuids = latestNote.tagGuids

      # merge all contents that are unique.
      loadFullNotes = orderedNotes.map (e) -> 
        d = Q.defer()
        evernote.getNote userInfo, e.guid, {}, (err, fullNote) ->
          d.resolve fullNote
        d.promise
        
      Q.all(loadFullNotes)
      .then (fullNotes) ->
        console.log fullNotes
        contentCollection = fullNotes.map (e) -> e.content
        uniqueContents = _.uniq contentCollection
        if uniqueContents.length == 1
          # all content is the same, just delete the rest.

        else
          console.log "TODO merge content"
          content = uniqueContents[0]

          # update content, delete the rest.
      
        _.rest( orderedNotes, latestNote).map (e) ->
          obj.deleteNote e
        
      

  # IMPROVE all calls to this method to move to a middleware, results passed back via req.
  serveEvernoteRequest: (req, res, callback) ->
    obj.initEdamUser(req)
    .then(callback)
    .fail (e)->
      console.error 
        msg: "error while serving evernote request"
        error: e
        trace: e.stack

      switch e.type
        when 'authentication'
          res.redirect '/authentication'

        else
          obj.sendError res, e

          
        
    .done()

  initEdamUser: (req) ->
    deferred = Q.defer()

    if !req.session.user 
      # new session for this client - get mackerel token, attempt to load vendor token.

      username = req.headers['x-username']
      username ||= req.query.username

      Q.fcall ->
        store.getCredentials( 'evernote', username)
      .then (credentialsSet)->
        credentials = _.sortBy( credentialsSet, (e) -> e.updatedAt ).reverse()[0]
        
        if credentials
          data = credentials.get 'credentials'
        else
          # raise error for client to handle and redirect to login.
          deferred.reject 
            type: 'authentication'
            msg: "no credentials from store."

      .then (data)->
        authToken = data.authToken

        getUserPromise = promisify evernote, 'getUser'
        getUserPromise authToken 

      .then (edamUser)->
        # if err
        #   res.send(err, 500) 
        #   return

        req.session.user = edamUser
        deferred.resolve edamUser
    else
      deferred.resolve req.session.user

    return deferred.promise


  findNotes: (userInfo, params) ->
    d = Q.defer()

    words = "sourceURL:#{params.url}"
    offset = 0
    count = 10  # CASE handle duplicate notes
    sortOrder = 'UPDATED'
    ascending = false

    evernote.findNotes userInfo,  words, { offset:offset, count:count, sortOrder:sortOrder, ascending:ascending }, (err, noteList)->
      if (err)
        obj.sendError res, err
        return
      else

      d.resolve noteList.notes

    d.promise


  deleteNote: (note) ->
    console.log "TODO delete note #{note}"
  



  urlToThumbnail: (thumbnailUrl) ->
    thumbnailDataB64 = _(thumbnailUrl.split(',')).last()
    thumbnailData = atob thumbnailDataB64
    ab = new ArrayBuffer(thumbnailData.length)
    ia = new Uint8Array(ab)
    for e, i in thumbnailData
      ia[i] = thumbnailData.charCodeAt(i)
    data = ia

    { data: data, dataB64: thumbnailDataB64 }
  
  
  