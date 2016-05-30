angular.module('epsilonApp').config ($routeProvider) ->
  templateRoot = "/templates"

  # Shortcut
  tr = templateRoot
  $routeProvider
    .when '/', {
      templateUrl: "#{tr}/index.html"
    }

    .when '/login', {
      templateUrl: "#{tr}/login.html"
    }

    .when '/lost-password', {
      templateUrl: "#{tr}/lost-password.html"
    }

    .when '/register', {
      templateUrl: "#{tr}/register.html"
    }

    .when '/about', {
      templateUrl: "#{tr}/about.html"
    }

    .otherwise {
      redirectTo: "/"
    }
