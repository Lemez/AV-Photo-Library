(function(app){
    "use strict";
    app.controller("MainCtrl", function($scope, $http, $window, filterService)
        {
            $scope.filterService = filterService;

            //a scope function to load the data.
            $scope.loadData = function () {
            console.log("LOADING");
              $http.get('/fetch_images').success(function(data) {
                 $scope.images = data;

                 $("#loading").hide();
                 $("#main-image-page").show();

                 $scope.gotoUrl = function(img){
                   $window.location.href = img.preview;
                 }

                 var keysNotWanted = ['aspect','drive_id','created_at','modified_at','preview','thumb_url','url'];
                 var keysWanted = ['category','tags','','name','title','extension','','width','height','aspect_ratio','size'];
                 
                 for (var i=0;i< $scope.images.length;i++){
                    var current = $scope.images[i];
                     var props = Object.keys(current).sort();

                     var tempString = '';

                     for (var k=0;k<keysWanted.length;k++){
                        var key = keysWanted[k];
                        var value = current[key];

                        if (key==='') {
                             tempString = tempString.concat("- \n ");
                        } else {

                            if (key==='size'){
                                value = parseFloat(parseInt(current[key])/1000000).toFixed(2).concat(" MB");
                            } 

                            tempString = tempString.concat(key)
                                .concat(": ")
                                .concat(value)
                                .concat("\n ");
                        }

                     $scope.images[i].full_metadata = tempString;
                     // console.log(tempString);
                    }
                }
                 
              });
            }   

    });
})(PFApp);

