angular.module 'epsilonApp'

  .controller 'epsilonController', ($location, $scope) ->
    epsilonCtrl = this

    # DEV NOTE: This should be made dynamic somewhere
    tabs = [ "/", "/login", "/register", "/about" ]

    epsilonCtrl.isActiveTab = (tab) ->
      return $location.path() == tab

    epsilonCtrl.tabClass = (tab) ->
      if epsilonCtrl.isActiveTab tab
        return 'active'
      else
        return ''


    epsilonCtrl.swipeHandler = (pos) ->
      # Disable on desktop
      return unless isMobile.any

      currentTab = tabs.indexOf $location.path()
      newTab = currentTab + pos

      if newTab < 0 || newTab >= tabs.length
        return

      $location.path tabs[newTab]

    # Swipe left = Go to tab right
    epsilonCtrl.swipeLeft = ->
      swipeHandler(+1)

    # Swipe right = Go to tab left
    epsilonCtrl.swipeRight = ->
      swipeHandler(-1)

    return
