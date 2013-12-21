
app.all('/test/throw', function(req, res, next) {
	var app2, doThrow, e;
	doThrow = function() {
		throw "test exception";
	};

	doThrow();
});

app.all('/test/throw2', function(req, res, next) {
	var app2, doThrow, e;
	doThrow = function() {
		throw "test exception";
	};

	setTimeout( function() {
		return doThrow();
	});
});

app.all('/test/throw3', function(req, res, next) {
	var app2, doThrow, e;
	doThrow = function() {
		throw "test exception";
	};

	Q.fcall(function(){

		doThrow();
	}).done();
});

