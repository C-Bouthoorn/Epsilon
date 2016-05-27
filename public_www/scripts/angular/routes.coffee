angular.module('epsilonApp').config ($routeProvider) ->
  $routeProvider
    .when '/', {
      templateUrl: "/templates/index.html"
    }

    .when '/login', {
      templateUrl: "/templates/login.html"
    }

    .when '/register', {
      templateUrl: "/templates/register.html"
    }

    .otherwise {
      redirectTo: '/'
    }
