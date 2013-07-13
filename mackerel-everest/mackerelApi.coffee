_ = require('lodash')
Q = require('Q')
promisify = require('when-promisify')

Parse = require('parse').Parse
Parse.initialize("RnNIA4148ExIhwBFNB9qMGci85tOOEBHbzwxenNY", "5FSg0xa311sim8Ok1Qeob7MLPGsz3wLFQexlOOgm")

Credentials = Parse.Object.extend 'Credentials'

module.exports = 

  setup: (app)=> 
    evernote = app.evernote

    app.store = store =
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
      

    # e.g. building a rest api
    # app.post '/mackerel/tags/:guid', (req, res) ->
    #   return res.send tag, 200

    sendData = (data, res)->
      res.header "Access-Control-Allow-Origin", "*"
      res.send data, 200


    # INSECURE
    app.all '/authentication/details', (req, res)->
      details = {}
      sendData details, res

    app.get '/mackerel/tags', (req, res) ->
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

      # fetchStickers: (page) ->
      #   Q.fcall ->
      #     obj.listTags()
      #   .then (tags)->
      #     obj.ifError tags, Q
          
      #     $log.info tags
      #     matchingTags = tags.filter (tag) -> tag.name.match app.userPrefs.sticker_prefix_pattern

      #     stickers = matchingTags.map (tag) ->
      #       sticker = new Sticker
      #         implObj: tag
      #         id: tag.guid
      #         name: tag.name

      #     return stickers

  
      # based on everest.js
      try
        Q.fcall ->
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

        .then ->
          userInfo = req.session.user

          evernote.listTags userInfo, (err, tagList) -> 
            if (err) 
              return res.send(err,403) if (err == 'EDAMUserException') 

              return res.send(err,500)
            else 
              # ODD only 20 at a time. why?

              sticker_prefix_pattern = /^##/
              matchingTags = tagList.filter (tag) -> tag.name.match sticker_prefix_pattern

              sendData matchingTags, res


      catch e
        console.log e
        return res.send('Unauthenticate',401);


    app.get '/mackerel/page', (req, res) ->
      page = 
        url: 'http://stub-url'
        stickers: [
          {
            name: "stub-sticker-3"
          }
        ]

      sendData page, res



    console.log('mackerel api initialised.')
    


