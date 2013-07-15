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


    app.get '/mackerel/tags', (req, res) =>
      stub_tags = [
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
        obj.fetchTags userInfo
      .then (tagList) ->
        obj.sendData tagList, res
      .fail (err) ->
        return res.send(err,403) if (err == 'EDAMUserException') 

        return res.send(err,500)


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
            return res.send(err,403) if (err == 'EDAMUserException')
            return res.send(err,500);
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
            return res.send(err,403) if (err == 'EDAMUserException')
            return res.send(err,500);
          else
            return obj.sendData noteList, res



    console.log('mackerel api initialised.')
    


  sendData: (data, res)->
    res.header "Access-Control-Allow-Origin", "*"
    res.send data, 200

  initEdamUser: (req) ->
    deferred = Q.defer()

    if !req.session.user 
      # new session for this client - get mackerel token, attempt to load vendor token.

      # TEMP dev-mode retrieval from parse
      store.getCredentials( 'evernote', 'sohocoke')
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


  fetchTags: (userInfo)->
    deferred = Q.defer()

    evernote.listTags userInfo, (err, tagList) -> 
      if (err) 
        deferred.reject err
      else
        sticker_prefix_pattern = /^##/
        tagList = tagList.filter (tag) -> tag.name.match sticker_prefix_pattern

        deferred.resolve tagList.map (tag) ->
          id: tag.guid
          name: tag.name


    deferred.promise


  
  