(function(app){
    "use strict";
    app.controller("FilterController", function($scope, filterService) { 
    
    $scope.filterService = filterService;
    $scope.getKeyOf = function(item) { 
    	var keys = Object.keys($scope.filterService.activeFilters);
    	
    	for (var i=0;i<keys.length;i++){

    		if ($scope.filterService.activeFilters[keys[i]]==item) {
    		
    				return keys[i];
    		}
    	}
    }

    $scope.remove = function() { $scope.filterService.activeFilters={};}

    });
})(PFApp);