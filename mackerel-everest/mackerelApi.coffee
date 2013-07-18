_ = require('lodash')
Q = require('Q')
promisify = require('when-promisify')

Parse = require('parse').Parse
Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

Credentials = Parse.Object.extend 'Credentials'

store  =
  getCredentials: (vendorId, username) ->
    q = new Parse.Query Credentials
    q.find( {
              vendorId
              username 
            })
    # TODO ensure we order results.


  setCredentials: (vendorId, username, credentials) ->
    new Credentials().save {
      vendorId
      username
      credentials
    }
evernote = null


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


    # necessary for successful post
    app.options '/mackerel/page', (req, res) ->
      res.header "Access-Control-Allow-Headers", "Content-Type, x-username"

      obj.sendData null, res

    app.options '/mackerel/stickers', (req, res) ->
      res.header "Access-Control-Allow-Headers", "Content-Type, x-username"

      obj.sendData null, res


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
      obj.initEdamUser(req)
      .then (userInfo)->
        obj.fetchStickers userInfo
      .then (stickers) ->
        obj.sendData stickers, res
      .fail (err) ->
        console.log err
        obj.sendError res, err

    app.post '/mackerel/stickers', (req, res) =>
      # create or update evernote tag.
      obj.initEdamUser(req)
      .then (userInfo)->

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

      .fail (err) ->
        obj.sendError res, err


    app.get '/mackerel/page', (req, res) =>
      stub_page = 
        url: 'http://stub-url'
        stickers: [
          {
            name: "stub-sticker-3"
          }
        ]

      obj.initEdamUser(req)
      .then (userInfo)->
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

            note = noteList.notes[0]

            note ||= 
              id: null
              title: req.query.title
              url: req.query.url
              tagGuids: []

            pageData = 
              id: note.id
              url: note.url
              title: note.title
              stickers: note.tagGuids.map (guid)->
                id: guid

            # if no previous note for this url
            pageData.stickers ||= []

            obj.sendData pageData, res

        
    app.post '/mackerel/page', (req, res) =>
      obj.initEdamUser(req)
      .then (userInfo)->

        note =
          title: req.title 
          tags: req.stickers.concat { name: 'Mackerel' }
          content: '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
  <en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;"><div>stub content</div>
  </en-note>'
          # TODO more properties
        
        evernote.createNote userInfo, note, (err, note) ->
          
          if (err) 
            obj.sendError res, err
            return
          
          obj.sendData note.guid, res


        # CASE updating the note.
        # CASE more posts before note fully created.


    # not part of public api

    app.get '/mackerel/notes', (req, res) =>
      obj.initEdamUser(req)
      .then (userInfo)->
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
  
  
  initEdamUser: (req) ->
    deferred = Q.defer()

    if !req.session.user 
      # new session for this client - get mackerel token, attempt to load vendor token.

      username = req.params.username
      store.getCredentials( 'evernote', username)
      .then (credentialsSet)->
        credentials = _.sortBy( credentialsSet, (e) -> e.updatedAt ).reverse()[0]
        data = credentials.get 'credentials'

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
  