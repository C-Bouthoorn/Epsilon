angular.module('epsilonApp').config ($routeProvider) ->
  templateRoot = "/templates"

  # Shortcut
  tr = templateRoot
  $routeProvider
    .when '/', {
      templateUrl: "#{tr}/index"
    }

    .when '/login', {
      templateUrl: "#{tr}/login"
    }

    .when '/lost-password', {
      templateUrl: "#{tr}/lost-password"
    }

    .when '/register', {
      templateUrl: "#{tr}/register"
    }

    .when '/about', {
      templateUrl: "#{tr}/about"
    }

    .otherwise {
      redirectTo: "/"
    }
