
// handle extrnal loading
var handleOpenURL = function(url) {
    window.localStorage.setItem("external_load", url);
};

// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
angular.module('starter', ['ionic',
  'relativeDate', 
  'ngCordova',
  'ngMessages',
  'dcbImgFallback',
  'starter.language',
  'starter.config',
  'starter.controllers', 
  'starter.notification',
  'starter.services', 
  'starter.resources', 
  'starter.authenticaion', 
  'starter.interceptors',
  'starter.directives', 
  'starter.models'])

.run(function($ionicPlatform, $cordovaSplashscreen, $cordovaDevice, $rootScope, Auth, Session, $state, $ionicLoading, Notification, $localstorage, $location, TrackService, $cordovaDialogs) {
  
  $ionicPlatform.ready(function() {

    $rootScope.$on('$cordovaNetwork:offline', function() {
      $cordovaDialogs.alert('Please check your device\'s connection!', 'Bad Network', 'OK');
    });

    // hide splash screen
    setTimeout(function(){
      $cordovaSplashscreen.hide();
    }, 1000)
    
    // initialize tracking service
    TrackService.isReady() && TrackService.init();

    Auth.onLoggedIn(function() {
      // when user logged in, send an event for tracking
      TrackService.isReady() && TrackService.track.setUserId(Session.user().id);

      // get push notification info
      var devicePushInfo = $localstorage.getObject('devicePushInfo');

      // update the the device info record stored on the server
      if (devicePushInfo.identity) {
          Notification.createDevice(
              devicePushInfo.identity,
              devicePushInfo.token,
              devicePushInfo.os
          );
      }

    });

    Auth.onLoggedOut(function() {

      // get push notification info
      var devicePushInfo = $localstorage.getObject('devicePushInfo');

      // update the the device info record stored on the server
      if (devicePushInfo.identity) {
          Notification.createDevice(
              devicePushInfo.identity,
              devicePushInfo.token,
              devicePushInfo.os
          );
      }

    });

    // reload session from storage
    Session.reload();

    // if session is invalid, go to login page
    if (!Session.valid()) {
      var savedUsers = $localstorage.getObject('savedUsers');
      if (Object.keys(savedUsers).length > 0) {
        $location.path('/app/loginas');
      }
    }

    // initialize notification service
    // wraped with timeout function, insure that it gets called after the session is set
    setTimeout(function(){
      Notification.init();
    }, 1000);

    // regeister notification callbacks
    $rootScope.$on('$cordovaPush:notificationReceived', $cordovaDevice.getPlatform() === 'Android' ? Notification.androidCallback : Notification.iosCallback);

    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    // if (window.cordova && window.cordova.plugins.Keyboard) {
    //   cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    // }
    
    if (window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleDefault();
    }

    // open external url
    var openExternalUrl = function() {
      var external_load_url = $localstorage.get('external_load', 'none');
      if (external_load_url !== 'null' && external_load_url !== null) {
        var parser = document.createElement('a');
        parser.href = external_load_url;
        $location.path('/app' + parser.pathname);
        $localstorage.set('external_load', null);
      }
    };

    // on app resume
    $ionicPlatform.on('resume', function(){     
        openExternalUrl();
    });

    openExternalUrl();

    // function to check the status of gps service
    function checkGPS() {
      cordova.plugins.diagnostic.isLocationEnabled(function(enabled){
          
          if (!enabled && /Android/.test(navigator.userAgent)) {

            $cordovaDialogs.confirm('To improve accuracy, we suggest to turn on the location service ?', 'Location Service', ['Yes', 'No']).then(function(index) {
              if(index == 1) {
                cordova.plugins.diagnostic.switchToLocationSettings();
              }
            });
            
          }
          else if(!enabled) {

            $cordovaDialogs.alert('To improve accuracy, we suggest to go to Settings and turn on the location service for Vicinity Deals.', 'Location Service', 'OK');

          }
      }, function(error){
          
      });
    };

    checkGPS();

    

  });

  // count of processing requests
  var requests = 0;

  // listen to loading:show events and show loading mask
  $rootScope.$on('loading:show', function() {
    requests ++;
    $ionicLoading.show({
      // template: 'loading...',
      animation: 'fade-in',
      showBackdrop: true,
      template: '<ion-spinner icon="dots"></ion-spinner>'
    });
  });

  // hide loading page
  $rootScope.$on('loading:hide', function() {
    requests --;
    requests || $ionicLoading.hide();
  });


  // listen to route state change events
  $rootScope.$on('$stateChangeStart', function(event, next, nextParams, from, fromParams) {
    
    TrackService.isReady() && TrackService.track.trackView(next.name);
    
    // if authorizedRoles specified,
    // check if logged in user is authorized
    if (next.data && next.data.authorizedRoles) { 
      // if not authorized, then go to login page
      if (!Auth.isAuthorized(next.data.authorizedRoles)) {
        event.preventDefault();
        $state.go('login');
      }
    }

  });

})

// Ionic uses
.config(function($provide, $stateProvider, $ionicConfigProvider, $compileProvider, $urlRouterProvider, gampConfig, $httpProvider) {

  $provide.decorator("$exceptionHandler", function($delegate, gampConfig) {
      return function (exception, cause) {

        if (typeof analytics !== 'undefined') {
          analytics.startTrackerWithId(gampConfig.googleAnalyticsID);
          analytics.trackEvent('error handler', cause + '', exception.message);
        }
        $delegate(exception, cause);
      };
  });

  // ionic settings
  $ionicConfigProvider.tabs.position('bottom');
  $ionicConfigProvider.tabs.style('standard');
  $ionicConfigProvider.navBar.alignTitle('center');
  $ionicConfigProvider.backButton.previousTitleText(true);
  $ionicConfigProvider.backButton.text('Back');
  $ionicConfigProvider.backButton.icon('ion-ios-arrow-back');
  $ionicConfigProvider.views.transition('ios');
  $ionicConfigProvider.views.swipeBackEnabled(false);

  // disalbe js scrolling on android platforms
  if (/Android/.test(navigator.userAgent)) {
    // alert($ionicConfigProvider.scrolling);
    $ionicConfigProvider.scrolling.jsScrolling(false);
  }

  /Android/.test(navigator.userAgent) && $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|file|blob|cdvfile):|data:image\//);
  // for some ations in resources, need to wrap params in model name
  $httpProvider.interceptors.push('modelWraperInterceptor');

  // set http request timout to 10 seconds
  $httpProvider.interceptors.push('timeoutInterceptor');

  // add query params intercepter,
  // which append apitoken and specified query params to the request url automaticlly
  $httpProvider.interceptors.push('queryParamsInterceptor');

  // add loading interceptor,
  // show loading page before and after http requests
  $httpProvider.interceptors.push('loadingInterceptor');

  // add error handlers
  $httpProvider.interceptors.push('errorInterceptor');

  // interceptor which handles uncache command
  $httpProvider.interceptors.push('uncacheInterceptor');

  // Ionic uses AngularUI Router which uses the concept of states
  // Learn more here: https://github.com/angular-ui/ui-router
  // Set up the various states which the app can be in.
  // Each state's controller can be found in controllers.js
  $stateProvider
  
  .state('app', {
    url: '/app',
    abstract: true,
    templateUrl: 'menu.html',
    controller: 'MenuCtrl',
    resolve: {
      reloadedSession: function(Session) {
        // return true;
        return Session.isReload();
      }
    }
  })

  .state('app.browse', {
    url: '/browse',
    views: {
      'menuContent': {
        templateUrl: 'templates/browse.html',
        controller: 'BrowseCtrl'      
      }
    }
  })

  .state('app.category', {
    url: '/category?category_id&title',
    views: {
      'menuContent': {
        templateUrl: 'templates/category.html',
        controller: 'CategoryCtrl',
        resolve: {
          categoryId: function($stateParams) {
            return $stateParams.category_id;
          },
          title: function($stateParams) {
            return $stateParams.title;
          }
        }
      }
    }
  })

  .state('app.search', {
    url: '/search?query',
    views: {
      'menuContent': {
        templateUrl: 'templates/search.html',
        controller: 'SearchCtrl',
        resolve: {
          initQuery: function($stateParams) {
            var query = $stateParams.query;
            return query;
          }
        }
      } 
    }
  })
  
  .state('app.profile', {
    url: '/users/:userid',
    views: {
      'menuContent': {
        templateUrl: 'templates/profile.html',
        controller: 'ProfileCtrl',
        resolve: {
          loadedUser: function(User, $stateParams) {
            console.log('loadedUser', $stateParams);
            var userid = $stateParams.userid;
            return User.get({ userId: userid }).$promise;      
          }
        }
      }
    }
  })

  .state('app.profile-edit', {
    url: '/users/:userid/profile-edit',
    views: {
      'menuContent': {
        templateUrl: 'templates/edit-profile.html',
        controller: 'EditProfileCtrl',      
        resolve: {
          loadedUser: function(User, $stateParams) {
            var userid = $stateParams.userid;
            return User.get({ userId: userid }).$promise;      
          }
        }
      }
    }
  })

  .state('app.promotion', {
    url: '/promotions/:promotionid',
    views: {
      'menuContent': {
        templateUrl: 'templates/promotion.html',
        controller: 'PromotionCtrl',
        resolve: {
          loadedPromotion: function(Promotion, $stateParams) {
            var promotionid = $stateParams.promotionid;
            return Promotion.get({ promotionId: promotionid }).$promise;
          }
        }
      }
    }
  })

  .state('app.comments', {
    url: '/comments?promotion_id&customer_id',
    views: {
      'menuContent': {
        templateUrl: 'templates/comments.html',
        controller: 'CommentsCtrl'
      }
    }
  })

  .state('app.promotions', {
    url: '/promotions?customer_id&page&per_page&sortBy&status',
    views: {
      'menuContent': {
        templateUrl: 'templates/promotions.html',
        controller: 'PromotionsCtrl',
        resolve: {
          loadedUser: function(User, $stateParams) {
            var userid = $stateParams.customer_id;
            return User.get({ userId: userid }).$promise;      
          }
        }
      }
    }
  })

  .state('app.store', {
    url: '/store',
    views: {
      'menuContent': {
        templateUrl: 'templates/membership.html',
        controller: 'StoreCtrl'
      }
    }
  })

  .state('app.account', {
    url: '/account',
    views: {
      'menuContent': {
        templateUrl: 'templates/settings/general.html',
        controller: 'SettingsCtrl'
      }
    }
  })

  .state('login', {
    url: '/login?jump_to&login_as',
    templateUrl: 'templates/login.html',
    controller: 'LoginCtrl'
  })

  .state('signup', {
    url: '/signup',
    templateUrl: 'templates/signup.html',
    controller: 'SignupCtrl'
  })

  .state('app.loginas', {
    url: '/loginas?jump_to',
    views: {
      'menuContent': {
        templateUrl: 'templates/loginas.html',
        controller: 'LoginasCtrl'
      }
    }
  });

  // $urlRouterProvider.otherwise('/app/search');
  $urlRouterProvider.otherwise('/app/browse');
  
});
