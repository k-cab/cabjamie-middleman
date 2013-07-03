// Generated by CoffeeScript 1.6.2
(function() {
  this.appModule = angular.module("appModule", ['ui', 'ngResource'], function($routeProvider, $locationProvider) {
    return $routeProvider.when("/", {
      templateUrl: 'templates/options.html',
      controller: 'AppCntl'
    }).otherwise({
      redirectTo: "/"
    });
  });

  this.appModule.controller('AppCntl', function($scope, $log, $location, $resource, userPrefs) {
    $scope.options = {
      env: {
        data: ['dev', 'production'],
        selection: userPrefs.env
      },
      localStorage: {
        data: _.map(Object.keys(localStorage), function(e) {
          return e + ": " + localStorage.getItem(e);
        }),
        actions: [
          {
            name: 'reset all',
            func: function() {
              var i, _i, _len, _results;

              $log.info("clearing everything in localStorage");
              _results = [];
              for (_i = 0, _len = localStorage.length; _i < _len; _i++) {
                i = localStorage[_i];
                _results.push(localStorage.clear(i));
              }
              return _results;
            }
          }
        ]
      }
    };
    return $scope.chooseKeyVal = function(key, val) {
      $log.info('todo');
      switch (key) {
        case 'env':
          userPrefs.set('env', val);
      }
      return $scope.options[key].selection = val;
    };
  });

}).call(this);
