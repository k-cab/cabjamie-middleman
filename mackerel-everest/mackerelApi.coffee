module.exports = 
	setup: -> 
		console.log('blahblah')
		
		# e.g. building a rest api
		app.post '/mackerel/tags/:guid', (req, res) ->
			return res.send tag, 200

