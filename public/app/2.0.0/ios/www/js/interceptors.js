angular.module('starter.interceptors', [])

.factory('uncacheInterceptor', function($cacheFactory) {
	var cache = $cacheFactory.get('$http');

	return {
		response: function(response) {
			if (response.config.params && response.config.params.uncache) {
				cache.remove(response.config.url);
				console.log('Resource has been uncached');
			}
			return response;
		}
	};
})

// set everyrequest's time to 10 s' 
.factory('timeoutInterceptor', function() {

	return {
		request: function(config) {
			config.timeout = 10000;
			return config;
		}
	};

})

// wrap data with model name.
// for example:
// { id:'123', age: 34, country: 'china' } => 
// 			{ user: { id:'123', age: 34, country: 'china' } }
.factory('modelWraperInterceptor', function() {
	
	return {
		request: function(config) {
			if (config.params && config.params.modelWraper) {
				console.log('modelWraper', config.params.modelWraper);
				var data = config.data;
				config.data = {};
				config.data[config.params.modelWraper] = data;
				delete config.params.modelWraper;
			}
			return config;
		}
	};
})

// append query params to each request if avaliable
.factory('queryParamsInterceptor', function(Session, GeoService, TrackService, $localstorage) {

	return {

		request: function(config) {	
		
			// TrackService.isReady() && TrackService.track.trackEvent('request', config.url, JSON.stringify(config.params));
			
			config.url += '?';
			var params = [];			
			if (!!Session.session && !!Session.session.apitoken) {
				params.push('apitoken=' + Session.session.apitoken);
			}
			if (GeoService.location()) {
				params.push('lat=' + GeoService.location().latitude);
				params.push('long=' + GeoService.location().longitude);
			}
			config.url += params.join('&');
			return config;
		},

		response: function(response) {
			if(response.config.track) {
				// console.log('response..', response.config.params);
				response.config.track.forEach(function(track) {
					// alert(track);
					TrackService.isReady() && TrackService.track.trackEvent(track.dimension, angular.isString(track.view) ? track.view : track.view(response.data, response.config.params), track.level(response.data, response.config.params));
					// TrackService.isReady() && TrackService.track.addCustomDimension(track.dimension, track.level(response.data, response.config.params));
					// TrackService.isReady() && TrackService.track.trackView(angular.isString(track.view) ? track.view : track.view(response.data, response.config.params));
				});
			}

			return response;
		}	
	};

})

// interceptor request with loading page
.factory('loadingInterceptor', function($rootScope, gampConfig) {

	return {

		request: function(config) {
			
			var show = gampConfig.loadingInterceptorMatchers.reduce(function(prev, curr) {
				var regexp = new RegExp(curr);
				return regexp.test(config.url) || prev;
			}, false);

			show && $rootScope.$broadcast('loading:show');
			config.show = show;

			return config;
		},

		response: function(response) {
			response.config.show && $rootScope.$broadcast('loading:hide');
			return response;
		}
	};

})


.factory('errorInterceptor', function($q, $location, $rootScope, Flash, $cordovaToast, Session, TrackService) {

	return {

		responseError: function(rejection) {

			console.log('[HTTP ERROR] start');
			console.log(JSON.stringify(rejection), null, 2);
			console.log('[HTTP ERROR] end');

			// hide the standing by mask when ever a error happens
			rejection.config.show && $rootScope.$broadcast('loading:hide');

			if (window.Connection && navigator.connection.type === Connection.NONE){

				Flash.setMessage('Network Disconnected!');
				return $q.reject(rejection);

			} else if (rejection.status === 404) {
				
				$cordovaToast.showShortBottom('The page you request no longer exists!');
				return $q.reject(rejection);

			} else if (rejection.status === 422) {
				var msg = '';
				if (rejection.data.fields && Object.keys(rejection.data.fields).length > 0) {
					for (var key in rejection.data.fields) {
						msg += key + ':: ' + rejection.data.fields[key] + '\n';
						break;
					}
				} else if (rejection.data.error){
					msg += rejection.data.error + '\n';
				}

				TrackService.isReady() && TrackService.track.trackEvent('Http Error', rejection.status, '[ '+ rejection.config.url + ' ]  ' + msg);
				Flash.setMessage(msg);

				return $q.reject(rejection);

			// destory sesion if session expired
			} else if (rejection.status === 401) {
				Session.destory();
				$location.path('/app/browse');
				return $q.reject(rejection);
			}

			// $cordovaToast.showLongBottom(rejection.data && rejection.data.error || 'unknown error, please try later.');
			TrackService.isReady() && TrackService.track.trackEvent('Http Error', rejection.status, '[ '+ rejection.config.url + ' ]  ' +(rejection.data.error || 'unknown error, please try later.'));

			Flash.setMessage(rejection.data && rejection.data.error || 'Unknown Error! Please try later.');
			return $q.reject(rejection);
		}

	};

});