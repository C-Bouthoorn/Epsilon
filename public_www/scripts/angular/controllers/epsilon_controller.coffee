angular.module('epsilonApp')

  .controller 'epsilonController', ($location, $scope) ->
    epsilonCtrl = this

    tabs = [ "/", "/login", "/register" ]

    epsilonCtrl.isActiveTab = (tab) ->
      return $location.path() == tab

    epsilonCtrl.swipeLeft = ->
      currentTab = tabs.indexOf($location.path())
      newTab = currentTab + 1

      if newTab >= tabs.length
        return

      $location.path tabs[newTab]

      # Remove focus from other tab
      

    epsilonCtrl.swipeRight = ->
      currentTab = tabs.indexOf($location.path())
      newTab = currentTab - 1

      if newTab < 0
        return

      $location.path tabs[newTab]


    return
