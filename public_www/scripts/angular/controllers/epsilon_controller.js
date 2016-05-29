// Generated by CoffeeScript 1.10.0
angular.module('epsilonApp').controller('epsilonController', function($location, $scope) {
  var epsilonCtrl, tabs;
  epsilonCtrl = this;
  tabs = ["/", "/login", "/register", "/about"];
  epsilonCtrl.isActiveTab = function(tab) {
    return $location.path() === tab;
  };
  epsilonCtrl.tabClass = function(tab) {
    if (epsilonCtrl.isActiveTab(tab)) {
      return 'active';
    } else {
      return '';
    }
  };
  epsilonCtrl.swipeLeft = function() {
    var currentTab, newTab;
    if (!isMobile.any) {
      return;
    }
    currentTab = tabs.indexOf($location.path());
    newTab = currentTab + 1;
    if (newTab >= tabs.length) {
      return;
    }
    return $location.path(tabs[newTab]);
  };
  epsilonCtrl.swipeRight = function() {
    var currentTab, newTab;
    if (!isMobile.any) {
      return;
    }
    currentTab = tabs.indexOf($location.path());
    newTab = currentTab - 1;
    if (newTab < 0) {
      return;
    }
    return $location.path(tabs[newTab]);
  };
});
