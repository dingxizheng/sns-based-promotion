angular.module('starter.notification', [])

// Notification Module
// this module provides abilities to regiester devices and send the device info 
// to the server
// 
// As well as handles the push messages
.service('Notification', function($rootScope, $cordovaPush, $http, $cordovaDevice, gampConfig, $localstorage, $cordovaLocalNotification, $state, $cordovaDialogs) {

    // ios configuration params
    var iosConfig = {
        "badge": true,
        "sound": true,
        "alert": true,
    };

    // android configuration params
    var androidConfig = {
        "senderID": "59000383391",
    };

    var self = this;


    // send the device information to the server side
    // including identity: (the dervice identity)
    //           token: push notification token ( address of the device to the push server )
    //           os: os name
    //           user_id (optional)
    this.createDevice = function(deviceId, token, os, user_id) {
        
        var params = {
            identity: deviceId,
            token: token,
            os: os
        };

        user_id && (params.user_id = user_id);

        $localstorage.setObject('devicePushInfo', params);

        return $http.post([gampConfig.baseUrl, gampConfig.devices].join('/'), {
            device: params
        });

    };

    this.init = function() {

        var pushConfig = iosConfig;
        if ($cordovaDevice.getPlatform() === 'Android') {
            pushConfig = androidConfig
        }

        return $cordovaPush.register(pushConfig).then(function(deviceToken) {
            $cordovaDevice.getPlatform() === 'iOS' && 
                self.createDevice($cordovaDevice.getUUID(), deviceToken, 'ios');
        }, function(err) {
            console.log(err);
        });

    };

    this.iosCallback = function(event, notification) {

        if (notification.alert) {
           var msg_id = new Date().getTime();
           $cordovaLocalNotification.add({
                id: msg_id,
                text: notification.alert
           }).then(function() {
                $cordovaLocalNotification.cancel(msg_id);
                $state.go('app.promotion', {
                    promotionid: notification.promotion_id
                });
           });
        }

        if (notification.sound) {
            var snd = new Media(event.sound);
            snd.play();
        }

    };

    this.androidCallback = function(event, notification) {
        
        switch (notification.event) {
            case 'registered':
                if (notification.regid.length > 0) {
                    self.createDevice($cordovaDevice.getUUID(), notification.regid, 'android');
                }
                break;

            case 'message':

                // if app is running at foreground
                if (notification.foreground) {

                    $cordovaDialogs.confirm(notification.message, 'Deal', ['Read', 'Cancel']).then(function(index) {

                        if (index === 1) {
                           $state.go('app.promotion', {
                                promotionid: notification.payload.promotion_id
                            }); 
                        }

                    });
                }
                // otherwise direct to the payloaded page 
                else {

                    $state.go('app.promotion', {
                        promotionid: notification.payload.promotion_id
                    });

                }

                break;

            case 'error':
                alert('GCM error = ' + notification.msg);
                break;

            default:
                alert('An unknown GCM event has occurred');
                break;
        }
    };

});
