// Generated by CoffeeScript 1.10.0
angular.module('epsilonApp').config(function($routeProvider) {
  return $routeProvider.when('/', {
    templateUrl: "/templates/index.html"
  }).when('/login', {
    templateUrl: "/templates/login.html"
  }).when('/register', {
    templateUrl: "/templates/register.html"
  }).otherwise({
    redirectTo: '/'
  });
});
