angular.module('starter.services', [])

// convert underscore.js as an angular service
.constant('_', window._)

.service('TrackService', function(gampConfig, Session) {

    this.init = function() {
        this.track = analytics;

        this.track.startTrackerWithId(gampConfig.googleAnalyticsID);

        Session.user().id && this.track.setUserId(Session.user().id);
    };

    this.isReady = function() {
        return typeof analytics !== 'undefined';
    };

    return this;
})

.service('RuntimeStorage', function() {

    this.data = {};

    this.set = function(key, data) {
        this.data[key] = data;
    };

    this.get = function(key) {
        if (this.data[key])
            return this.data[key];
        else {
            this.set(key, {});
            return this.data[key];
        }
    };

    return this;
})

.factory('ControllerService', function() {

    var onEnterCallbacks = {};
    var onExitCallbacks = {};

    return {

        execOnEnter: function(name) {
            return onEnterCallbacks[name];
        },

        execOnExit: function(name) {
            return onExitCallbacks[name];
        },

        onEnter: function(name, callback) {
            onEnterCallbacks[name] = callback;
        },

        onExit: function(name, callback) {
            onExitCallbacks[name] = callback;
        }

    };

})

// Service provides ability to convert address a map image
.factory('MapImg', function(gampConfig) {

    return function() {

        var url = gampConfig.mapImgUrl;

        return {

            get: function() {
                return url;
            },

            center: function(addr) {
                url += 'center=' + encodeURIComponent(addr) + '&';
                return this;
            },

            size: function(width, height) {
                url += 'size=' + width + 'x' + height + '&';
                return this;
            },

            zoom: function(scale) {
                url += 'zoom=' + scale + '&';
                return this;
            },

            markers: function(color, label, addr) {
                url += 'markers=color:' + color + '%7Clabel:' + label + '%7C' + encodeURIComponent(addr) + '&';
                return this;
            }

        };

    };
})

.service('SearchParams', function() {

    var params = {};

    var searchFn = function() {};

    this.set = function(name, value) {
        params[name] = value;
    };

    this.get = function() {
        return params
    };

    this.search = function() {
        searchFn(params);
    };

    this.onSearch = function(fn) {
        searchFn = fn;
    };

    this.reset = function() {
        params = {};
    };

})

.factory('Flash', function($cordovaDialogs) {

    var queue = [];

    return {
        setMessage: function(message, type) {
            $cordovaDialogs.alert(message, 'Message', 'Close');
        },

        readMessage: function() {
            // queue.shift();
        }
    };

})

.service('Utils', function() {

    this.autoExpand = function(e) {
        var element = typeof e === 'object' ? e.target : document.getElementById(e);
        var scrollHeight = element.scrollHeight < 20 ? 20 : element.scrollHeight;
        element.style.height = scrollHeight + "px";
    };

    return this;
})

.service('Loading', function() {

    this.show = false;

    return this;
})

.service('GeoService', function($cordovaGeolocation) {

    var posOptions = {
        timeout: 10000,
        enableHighAccuracy: false
    };
    var coords = null;

    this.refresh = function() {
        return $cordovaGeolocation.getCurrentPosition(posOptions).then(function(pos) {
            coords = pos.coords;
            return coords;
        });
    };

    this.location = function() {
        return coords;
    };

    this.refresh();

    return this;
})

.service('Loading', function() {

    this.show = false;

    return this;
})

.factory('$localstorage', ['$window', function($window) {

    return {

        set: function(key, value) {
            $window.localStorage[key] = value;
        },

        get: function(key, defaultValue) {
            return $window.localStorage[key] || defaultValue;
        },

        setObject: function(key, value) {
            $window.localStorage[key] = angular.toJson(value);
        },

        getObject: function(key) {
            return JSON.parse($window.localStorage[key] || '{}');
        }

    };

}]);
