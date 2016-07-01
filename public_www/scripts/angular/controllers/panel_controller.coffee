angular.module 'epsilonApp'

  .controller 'epsilonPanelController', ['$location', '$scope', ($location, $scope) ->
    panelCtrl = this

    panelCtrl.session = {
      id: 0
    }

    # Get session
    $.post '/api/panel/get', { get: 'session' }, (data) ->
      console.log data

      panelCtrl.session.id = data.id
      $scope.$apply()

    return
  ]
