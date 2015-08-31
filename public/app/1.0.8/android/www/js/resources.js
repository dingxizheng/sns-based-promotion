angular.module('starter.resources', ['ngResource'])

.factory('Catagory', function($resource, gampConfig) {

    // construct the resource url
    var url = [gampConfig.baseUrl, gampConfig.catagorys, ':catagoryId'].join('/');

    return $resource(url, {
        catagoryId: '@id'
    }, {
        'query': {
            method: 'GET',
            cache: true,
            isArray: true
        },
        'update': {
            method: 'PUT',
            modelWraper: 'catagory'
        }
    });
})

.factory('Search', function($http, gampConfig) {

    var url = [gampConfig.baseUrl, 'search'].join('/');

    return {
        query: function(params) {
            return $http.get(url, { params: params });
        }
    };

})

.factory('Promotion', function($resource, gampConfig) {

    // construct the resource url
    var url = [gampConfig.baseUrl, gampConfig.promotions, ':promotionId'].join('/');

    // construct the resource to be returned
    return $resource(url, {
        promotionId: '@id'
    }, {
        'get': {
            method: 'GET',
            cache: true
        },
        'save': {
            method: 'POST',
            params: {
                modelWraper: 'promotion'
            }
        },
        'reject': {
            method: 'POST',
            params: {
                promotionId: '@id'
            },
            url: url + '/reject'
        },
        'report': {
            method: 'POST',
            params: {
                promotionId: '@id'
            },
            url: url + '/report'
        },
        'approve': {
            method: 'POST',
            params: {
                promotionId: '@id'
            },
            url: url + '/approve'
        },
        'update': {
            method: 'PUT',
            params: {
                modelWraper: 'promotion'
            }
        },
        'rate': {
            method: 'POST',
            params: { 
                promotionId: '@id'            
            },
            url: url + '/rate'
        },
        'notify': {
            method: 'POST',
            params: {
                promotionId: '@id',
            },
            url: url + '/notify'
        }
    });
})

.factory('Review', function($resource, gampConfig) {

    // construct the resource url
    var url = [gampConfig.baseUrl, gampConfig.reviews, ':reviewId'].join('/');

    // construct the resource to be returned
    return $resource(url, {
        reviewId: '@id'
    }, {
        'update': {
            method: 'PUT',
            params: {
                modelWraper: 'review'
            }
        }
    });

})

// file uploading module
// upload given file to the specified location
.factory('FileUploader', function($q, $rootScope) {

	return function(name, fileUri, url) {

		var deferred = $q.defer();

	    var options = new FileUploadOptions();
        options.fileKey = name;
        options.fileName = fileUri.substr(fileUri.lastIndexOf('/') + 1);
        // options.mimeType = "image/jpeg";

        var params = {};
        options.params = params;

        var ft = new FileTransfer();
        $rootScope.$broadcast('loading:show');

        ft.upload(fileUri, url, function(data) {

        	$rootScope.$broadcast('loading:hide');
        	deferred.resolve(data);

        }, function(err) {

        	$rootScope.$broadcast('loading:hide');
        	deferred.reject(err);

        }, options);

        return deferred.promise;

	};

})

.factory('User', function($resource, gampConfig) {

    // construct the resource url
    var url = [gampConfig.baseUrl, gampConfig.users, ':userId'].join('/');

    // construct the resource to be returned
    return $resource(url, {
        userId: '@id'
    }, {
        'get': {
            method: 'GET',
            cache: true
        },
        'update': {
            method: 'PUT',
            params: {
            	modelWraper: 'user',
                uncache: true
            }
        },

        'addTag': {
        	method: 'POST',
        	data: {},
        	params: { userId: '@id' },
        	url: url + '/keywords'
        },

        'deleteTag': {
        	method: 'DELETE',
        	params: { userId: '@id' },
        	url: url + '/keywords/:keyword'
        },

        'reset': {
            method: 'POST',
            params: { userId: '@id' },
            url: url + '/reset'
        },

        'newpassword': {
            method: 'POST',
            params: { userId: '@id' },
            url: url + '/newpassword'
        },

        'rate': {
            method: 'POST',
            params: { 
                userId: '@id'            
            },
            url: url + '/rate'
        }
    });
})

.factory('Subscription', function($resource, gampConfig) {

    // construct the resource url
    var url = [gampConfig.baseUrl, gampConfig.subscriptions, ':subscriptionId'].join('/');

    // construct the resource to be returned
    return $resource(url, {
        subscriptionId: '@id'
    }, {
        'get': {
            method: 'GET',
            cache: true
        },
        'save': {
            method: 'POST',
            params: {
                modelWraper: 'subscription'
            }
        },
        'update': {
            method: 'PUT',
            params: {
                modelWraper: 'subscription'
            }
        },
        'products': {
            method: 'GET',
            url: [gampConfig.baseUrl, 'products'].join('/'),
            cache: true,
            isArray: true
        }
    });
});