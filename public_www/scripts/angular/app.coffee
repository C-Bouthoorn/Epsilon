# Init module
angular.module 'epsilonApp', [ 'ngRoute', 'ngTouch' ]

# Show desktop site when user requests so (Chrome: Request desktop site)
unless isMobile.any
  reView.setDefault()
