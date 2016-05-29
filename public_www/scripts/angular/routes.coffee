angular.module('epsilonApp').config ($routeProvider) ->
  $routeProvider
    .when '/', {
      templateUrl: "/templates/index.html"
    }

    .when '/login', {
      templateUrl: "/templates/login.html"
    }

    .when '/lost-password', {
      templateUrl: "/templates/lost-password.html"
    }

    .when '/register', {
      templateUrl: "/templates/register.html"
    }

    .when '/about', {
      templateUrl: "/templates/about.html"
    }

    .otherwise {
      redirectTo: '/'
    }
