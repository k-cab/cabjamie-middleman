var appModule = angular.module('appModule', [], function($routeProvider, $locationProvider) {
	
	$routeProvider.when('/', {
		templateUrl: 'templates/index.html',
		controller: AppCntl
	});

});

var AppCntl = function ($scope) {
	$scope.addSticker = function(el) {
		console.log({ obj: el, msg: 'add sticker'});
	};
};

