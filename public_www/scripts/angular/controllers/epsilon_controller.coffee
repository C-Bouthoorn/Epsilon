angular.module 'epsilonApp'

  .controller 'epsilonController', ($location, $scope) ->
    epsilonCtrl = this

    # DEV NOTE: This should be made dynamic somewhere
    tabs = [ "/", "/login", "/register", "/about" ]

    # Check if tab is active tab
    epsilonCtrl.isActiveTab = (tab) ->
      return $location.path() == tab

    # Get the class for the tab
    epsilonCtrl.tabClass = (tab) ->
      if epsilonCtrl.isActiveTab tab
        return 'active'
      else
        return ''

    # Handle swipes
    epsilonCtrl.swipeHandler = (pos) ->
      # Disable on desktop
      return unless isMobile.any

      currentTab = tabs.indexOf $location.path()
      newTab = currentTab + pos

      # Check boundaries
      unless 0 <= newTab < tabs.length
        return

      # Set new path
      $location.path tabs[newTab]

    # Swipe left = Go to tab right
    epsilonCtrl.swipeLeft = ->
      epsilonCtrl.swipeHandler(+1)

    # Swipe right = Go to tab left
    epsilonCtrl.swipeRight = ->
      epsilonCtrl.swipeHandler(-1)

    return
