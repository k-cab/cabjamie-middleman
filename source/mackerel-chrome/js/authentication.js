// Generated by CoffeeScript 1.6.2
(function() {
  angular.module('appModule').controller('AuthenticationCntl', function($scope, $rootScope, $log, $location, globalsSvc) {
    var initialPath;

    if ($location.path().match(/logout/)) {
      return $rootScope.authentication.setLoggedOut();
    } else if ($location.path().match(/login/)) {
      initialPath = $location.absUrl().replace(/#.*/, '');
      return localStorage.setItem("oauth_success_redirect_path", initialPath);
    }
  });

}).call(this);
