module.exports = 
	setup: (app)-> 
		console.log('mackerel api initialised.')
		
		# e.g. building a rest api
		# app.post '/mackerel/tags/:guid', (req, res) ->
		# 	return res.send tag, 200

		app.all '/authentication/details', (req, res)->
			res.header "Access-Control-Allow-Origin", "*"
			res.send(details, 200)


		app.get '/mackerel/tags', (req, res) ->
			tags = [
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

			res.header("Access-Control-Allow-Origin", "*");
			res.send tags, 200
