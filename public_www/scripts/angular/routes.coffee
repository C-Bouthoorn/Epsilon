angular.module('epsilonApp').config ['$routeProvider', ($routeProvider) ->
  # Template Root
  tr = "/templates"

  # Set routes
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


    .when '/panel/', {
      templateUrl: "#{tr}/panel/index"
      controller: 'epsilonPanelController'
      controllerAs: 'panelCtrl'
    }

    .otherwise {
      redirectTo: "/"
    }

  return
]
