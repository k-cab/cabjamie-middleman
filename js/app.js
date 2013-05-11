var appModule = angular.module('appModule', [], function($routeProvider, $locationProvider) {
	
	$routeProvider.when('/', {
		templateUrl: 'templates/index.html',
		controller: AppCntl
	});

});

var AppCntl = function ($scope) {
	$scope.stickers = [
		{
			name: 'stub-sticker-1'
		},
		{
			name: 'stub-sticker-2'
		},
		{
			name: 'stub-sticker-3'
		},
	];		

	$scope.page = null; // TODO

	$scope.addSticker = function(sticker) {
		console.log({ obj: sticker, msg: 'add sticker'});

		// $scope.page.addSticker(sticker);
	};
};

