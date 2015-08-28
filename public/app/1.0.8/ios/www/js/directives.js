angular.module('starter.directives', [])

.directive('autoexpand', function(Utils) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            // alert(element[0].style);
            var dom = element[0];
            element.on('keypress', function() {
                Utils.autoExpand({ target: dom });
            });
            setTimeout(function() {
                Utils.autoExpand({ target: dom });
            }, 300);
        }
    };
})

.directive('gampcard', function(MapImg, Auth, formatters) {

    return {
        restrict: 'E',
        scope: {
            item: '=ngModel'
        },
        link: function(scope, element, attrs) {
			console.log(scope);
			console.log('loads template:', 'templates/cards/' + attrs['templateurl']);
			scope.finalTemplateUrl = 'templates/cards/' + attrs['templateurl'];
            
            scope.formatters = formatters;

            scope.getmap = function(address) {
               return new MapImg().center(address).zoom(14).size(150, 150).get();   
            };

            scope.editable = function(id) {
                return Auth.owns(id) || Auth.isAuthorized('admin');
            };
            // scope.editable = Auth.owns(scope.item.customer.id) || Auth.isAuthorized('admin');
		},
    };
})

.directive('mycard', function() {
	return {
		replace: true,
		template: '<ng-include src="finalTemplateUrl + \'\' "></ng-include>'
	};
})

// this directive is used to replace broken images with default ones
.directive('errSrc', function() {
    return {
        link: function(scope, element, attrs) {

            scope.$watch(function() {
                return attrs['ngSrc'];
            }, function(value) {
                if (!value) {
                    element.attr('src', attrs.errSrc);
                }
            });

            element.bind('error', function() {
                element.attr('src', attrs.errSrc);
            });
        }
    }
});
