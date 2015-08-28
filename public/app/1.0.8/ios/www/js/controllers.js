angular.module('starter.controllers', [])

.controller('AppCtrl', function($scope, Flash, Loading) {
    $scope.loading = Loading;
    $scope.flash = Flash;
})

// Menu Controller
.controller('MenuCtrl', function($scope, $injector, $state, Auth, Session, $cordovaInAppBrowser, $ionicActionSheet) {
    $scope.lang = $injector.get('englishLang');

    $scope.goToProfile = '#/login';
    $scope.goToStore = '#/login?jump_to=' + encodeURIComponent('/app/store');
    $scope.logoImage = false;

    var options = {
      location: 'yes',
      clearcache: 'yes',
      toolbar: 'yes'
    };

    $scope.openlink = function(link) {
        $cordovaInAppBrowser.open(link, '_system', options)
              .then(function(event) {
                // success
              })
              .catch(function(event) {
                // error
              });
    };

    Auth.onLoggedIn(function() {
        $scope.isLoggedin = true;
        $scope.goToProfile = '#/app/users/' + Session.user().id;
        $scope.goToStore = '#/app/store';
        if (Session.user().logo) {

            $scope.logoImage = Session.user().logo.thumb_url;
        }
    });

    Auth.onLoggedOut(function() {
        $scope.isLoggedin = false;
        $scope.goToProfile = '#/login';
        $scope.goToStore = '#/login?jump_to=' + encodeURIComponent('/app/store');
        $scope.logoImage = false;
    });

    $scope.logout = function() {
        Auth.logout();
    };

    var socialButtons = [
        {
            text: 'Twitter',
            link: 'https://twitter.com/vicinitydeals',
            icon: 'icon fa fa-twitter-square',
        },{
            text: 'Facebook',
            link: 'https://www.facebook.com/vicinitydeals',
            icon: 'icon fa fa-facebook-square',        
        }, {
            text: 'Instagram',
            link: 'https://instagram.com/vicinitydeals/',
            icon: 'icon fa fa-instagram'          
        }
    ];

    $scope.goToSocialPage = function() {
        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent)){
                    return socialButtons.map(function(b) { b.text = '<i class="'+ b.icon +'"></i> ' + b.text; return b; });
                }
                else
                    return socialButtons;
            }(),
            titleText:  'Go to our page on',
            cancelText: 'Cancel',
            buttonClicked: function(index) {
                $scope.openlink(socialButtons[index].link);
                return true;
            }
        });
    };

})

.controller('SearchCtrl', function($injector, $scope, $ionicSideMenuDelegate, Search, User, Promotion, initQuery, $ionicScrollDelegate, Session, $state, ControllerService, $localstorage, TrackService) {
    
    $scope.lang = $injector.get('englishLang');

    // toggleLeft menus
    $scope.toggleLeft = function() {
        $ionicSideMenuDelegate.toggleLeft();
    };

    // prevent the control from loading at the first time
    $scope.search_done = [true, true, true];
    // ids that has to be excluded
    $scope.ids = [];

    $scope.tabIndex = 0;

    $scope.search_type = 'user,,promotion';

    $scope.results =[
        { ads: [], normal: [] },
        { ads: [], normal: [] },
        { ads: [], normal: [] }
    ];

    $scope.blank_page = [true, true, true];

    $scope.page = [0, 0, 0];

    $scope.isEmpty = function(index) {
       return $scope.results[index].ads.length + $scope.results[index].normal.length === 0;
    };

    $scope.onTabSelect = function(index) {
        $scope.tabIndex = index;
        switch(index) {
            // set it to search only on users
            case 0: $scope.search_type = 'user'; break;
            // set it to search only on promotions
            case 1: $scope.search_type = 'promotion'; break;
            // set it to search on both tables
            default: $scope.search_type = 'user,,promotion';
        }
    };

    $scope.search = function(query) {
        if ($scope.tabIndex > 2) {
            return;
        }
        $scope.blank_page[$scope.tabIndex] = false;
        $scope.search_done[$scope.tabIndex] = false;
        $scope.query = query;
        $scope.page[$scope.tabIndex] = 1;
        $scope.results[$scope.tabIndex].ads = [];
        $scope.results[$scope.tabIndex].normal = [];
        $ionicScrollDelegate.scrollTop();
        $scope.loadAds().then(function(ids) {
            $scope.ids = ids;
            $scope.loadNext($scope.tabIndex);
        });
    };

    $scope.loadAds = function() {
        var query_params = {
            query: $scope.query,
            per_page: 3,
            subscripted: true,
            query_scope: $scope.search_type
        };
        var settings = $localstorage.getObject('searchSettings');
        if (settings.enable){
            query_params.distance = settings.distance;
        }
        return Search.query(query_params).then(function(res) {
            $scope.results[$scope.tabIndex].ads = res.data;
            return $scope.results[$scope.tabIndex].ads.map(function(result) {
                return result.result.id;
            });
        });
    };

    $scope.loadNext = function(index) {
        var query_params = { 
            excludes: $scope.ids.join(',,'),
            query: $scope.query, 
            page: $scope.page[index],
            query_scope: $scope.search_type
        };
        var settings = $localstorage.getObject('searchSettings');
        if (settings.enable){
            query_params.distance = settings.distance;
        }

        // track search history
        TrackService.track.trackEvent('search', $scope.search_type, JSON.stringify(query_params));

        !$scope.search_done[index] && Search.query(query_params).then(function(res) {
            $scope.page[index] ++;
            $scope.results[index].normal = $scope.results[index].normal.concat(res.data);
            res.data.length === 0 && ($scope.search_done[index] = true);
            res.data.length === 0 && $scope.get_suggested_items(index);
            $scope.$broadcast('scroll.infiniteScrollComplete');
        }, function() {
            $scope.search_done[index] = true;
            $scope.$broadcast('scroll.infiniteScrollComplete');
        });
    };

    $scope.get_suggested_items = function(index) {
        switch(index) {
            case 0: $scope.get_suggested_dealers(); break;
            case 1: $scope.get_suggested_promotions(); break;
            case 2: 
               $scope.get_suggested_dealers(); 
               $scope.get_suggested_promotions(); 
               break;
            default: true;
        }
    };

    // get the suggested dealers
    $scope.suggested_dealers = [];
    $scope.suggested_promotions = [];

    $scope.get_suggested_dealers = function() {
        var duration = 1 * 60 * 60 * 1000;
        var suggestedItems = $localstorage.getObject('suggestedItems');
        if (suggestedItems.dealers && suggestedItems.dealers.time + duration > new Date().getTime()) {
            $scope.suggested_dealers = suggestedItems.dealers.data;
        } else {
            User.query({
                within: 100000,
                page: 1,
                per_page: 4,
                user_role: 'customer',
                sortBy: '-subscripted'
            }).$promise.then(function(data) {
               $scope.suggested_dealers = data;
               suggestedItems.dealers = {
                    time: new Date().getTime(),
                    data: data
               };
               $localstorage.setObject('suggestedItems', suggestedItems);
            });
        }
    };

    $scope.get_suggested_promotions = function() {
        var duration = 1 * 60 * 60 * 1000;
        var suggestedItems = $localstorage.getObject('suggestedItems');
        if (suggestedItems.promotions && suggestedItems.promotions.time + duration > new Date().getTime()) {
            $scope.suggested_promotions = suggestedItems.promotions.data;
        } else {
            Promotion.query({
                within: 100000,
                page: 1,
                per_page: 4,
                sortBy: '-subscripted'
            }).$promise.then(function(data) {
               $scope.suggested_promotions = data; 
               suggestedItems.promotions = {
                    time: new Date().getTime(),
                    data: data
               };
               $localstorage.setObject('suggestedItems', suggestedItems);
            });
        }
    };


    ControllerService.onEnter('search', function(qstr) {
        $scope.search(qstr);
    });

    initQuery && ($scope.query = initQuery);
    initQuery && $scope.search(initQuery);

    setTimeout(function() {
        $scope.get_suggested_items(2);
    }, 1500)

})

.controller('SearchSetttingsCtrl', function($injector, $scope, $localstorage) {

    $scope.settingslang = $injector.get('englishLang');

    $scope.settings = $localstorage.getObject('searchSettings');

    $scope.settings.distance = $scope.settings.distance || 5;

    $scope.settings.enable = $scope.settings.enable || false;

    $scope.update = function() {
        $localstorage.setObject('searchSettings', $scope.settings);
    };

})

.controller('SettingsCtrl', function($scope) {

})

.controller('ProfileCtrl', function($ionicSideMenuDelegate, $rootScope, $scope, MapImg, $ionicActionSheet, loadedUser, $state, $location, Auth, Session, Promotion, User, $cordovaSocialSharing, $cordovaEmailComposer, $cordovaToast, EditPromotion, NewPassword, TrackService, MakeReview, Review) {

    $rootScope.$on('$ionicView.beforeEnter', function(e, data){
        $scope.isBackButtonShown = data.enableBack;
    });


    // toggleLeft menus
    $scope.toggleLeft = function() {
        $ionicSideMenuDelegate.toggleLeft();
    };

    // get the user
    $scope.customer = loadedUser;

    $scope.editiable = Auth.owns(loadedUser.id) || Auth.isAuthorized('admin');

    $scope.isCustomer = loadedUser.roles.indexOf('customer') !== -1;
    
    Auth.onLoggedIn(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = Auth.owns(loadedUser.id) || Auth.isAuthorized('admin');
    });

    Auth.onLoggedOut(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = false;
    });    

    $scope.keywords = loadedUser.keywords.reduce(function(pre, next) {
        return pre += '<span style="color: #C57477">#' + next + '<span>  '
    }, '');

    $scope.hours = Object.keys(loadedUser.hours);

    $scope.showMore = false;

    // get background picture
    $scope.mapurl = new MapImg().center(loadedUser.address).zoom(17).size(800, 400).markers('red', 'S', loadedUser.address).get();

    Promotion.query({
        customer_id: loadedUser.id,
        page: 1,
        per_page: 1,
        status: 'reviewed',
        expire_at: '>' + new Date().toString(),
        sortBy: '-created_at'
    }).$promise.then(function(promotions) {
        if (promotions[0])
            $scope.latestPromotion = promotions[0];
    });

    // navigate to the user's address
    $scope.navigate = function() {
        launchnavigator.navigate(
          loadedUser.address,
          null,
          function(){
            
          },
          function(error){
            
          },
          {
            preferGoogleMaps: true,
            enableDebug: true
        });
    };

    // show tags menu
    $scope.showTagsMenu = function(list) {
        var data = list.map(function(item) {
            return { text: '#' + item };
        });
        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent))
                    return data.map(function(b) { b.text = '<i class="icon ion-ios-pricetag-outline"></i> ' + b.text; return b; });
                else
                    return data;
            }(),
            titleText:  'Search by Tag',
            cancelText: 'Cancel',
            buttonClicked: function(index) {
                $location.path('/searchview/' + list[index]);
                return true;
            }
        });
    };

    $scope.doRefresh = function() {
        User.get({userId: loadedUser.id}).$promise.then(function(user) {
            $scope.customer = user;
            $scope.$broadcast('scroll.refreshComplete');
        }, function() {
            $scope.$broadcast('scroll.refreshComplete');
        });
    };


    $scope.emailUser = function() {
        var email = {
            to: loadedUser.email,
            subject: loadedUser.name,
            body: 'Hi, ' + loadedUser.name + ' <br>',
            isHtml: true
        };

        $cordovaEmailComposer.open(email);
    };

    $scope.review = function() {
        MakeReview.init($scope, {
            rating: 0
        }, function(rating, comment) {

            $scope.customer.$rate({ rating: rating }).then(function(res) {
                
                $scope.customer.rating = res.rating;
                $scope.customer.rates = res.rates;
                $cordovaToast.showShortBottom('Rated successfully!');
                // return !!comment && !!comment.length;

            }).finally(function(arg) {

                if (!comment || !comment.length) 
                    return;

                var review = new Review();
                review.review = {
                    body: comment,
                    customer_id: $scope.customer.id
                };
                review.$save().then(function() {
                    $cordovaToast.showShortBottom('Commented successfully!');
                });

            });

        })
        .then(function() {
            MakeReview.show();
        });
    };

    $scope.showReviewMenu = function() {
        var buttons = [
            {
                text: 'Make a review',
                icon: 'icon ion-ios-chatbubble',
                action: $scope.review
            },
            {
                text: 'Show all reviews',
                icon: 'icon ion-ios-chatboxes-outline',
                action: function() {
                    $state.go('app.comments', { customer_id: $scope.customer.id })
                    // $location.path('/comments?customer_id=' + $scope.customer.id);
                }
            }
        ];
        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent))
                    return buttons.map(function(b) { b.text = '<i class="'+ b.icon +'"></i> ' + b.text; return b; });
                else
                    return buttons;
            }(),
            titleText:  'Reviews',
            cancelText: 'Cancel',
            buttonClicked: function(index) {
                buttons[index].action();
                return true;
            }
        });
    };

    $scope.showMoreMenu = function() {
        var buttons = $scope.isCustomer ? [
            {
                text: 'Share This',
                icon: 'icon ion-share',
                action: $scope.share
            },{
                text: 'View All Deals',
                icon: 'icon ion-eye',
                action: $scope.viewAllPromotions
            }
        ] : [];

        $scope.editiable && buttons.push({
            text: 'Edit Profile',
            icon: 'icon ion-edit',
            action: function() {
                $location.path('/app/users/' + loadedUser.id + '/profile-edit');
            }
        });

        $scope.isCustomer && $scope.editiable && buttons.push({
            text: 'New Promotion',
            icon: 'icon ion-plus-round',
            action: $scope.newPromotion
        });

        Auth.owns(loadedUser.id) && buttons.push({
            text: 'Change Password',
            icon: 'icon ion-lock-combination',
            action: $scope.newPassword
        });

        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent))
                    return buttons.map(function(b) { b.text = '<i class="' + b.icon + '"></i>' + b.text; return b; });
                else
                    return buttons;
            }(),
            titleText:  'Options',
            cancelText: 'Cancel',
            buttonClicked: function(index) {
                buttons[index].action();
                return true;
            }
        });
    };

    $scope.newPassword = function() {
        NewPassword.init($scope, function(c, n) {
            
            loadedUser.$newpassword({
                current_password: c,
                new_password: n
            }).then(function() {
                $cordovaToast.showShortBottom('Password has been changed successfully!');
                NewPassword.hide();
                NewPassword.remove();

                Session.destory();
                $location.path('/login');

            });

        }).then(function() {
            NewPassword.show();
        });
    };

    $scope.viewAllPromotions = function() {
        $location.path('/app/promotions').search('customer_id', loadedUser.id);
    };

    $scope.newPromotion = function() {
        EditPromotion.init($scope, {
            title: 'New Promotion',
            promotion: new Promotion({})
        }, function(deal) {
            deal.$save({ user_id: loadedUser.id }).then(function() {
                $cordovaToast.showShortBottom('Deal created successfully');
                EditPromotion.hide();
                EditPromotion.remove();
            });
            return false;
        }).then(function() {
            EditPromotion.show();
        }); 
    };

    $scope.share = function() {
        $cordovaSocialSharing
            .share('[Vicinity Deals][' + loadedUser.name + '][' + loadedUser.address + ']', loadedUser.description, null, loadedUser.url + '?format=html')
            .then(function(result) {
              TrackService.isReady() && TrackService.track.trackEvent('share', 'business [' + loadedUser.id  + ']', JSON.stringify(loadedUser));
            }, function(err) {
              // An error occured. Show a message to the user
            });
    };
})

.controller('EditProfileCtrl', function($scope, loadedUser, FileUploader, Session, Flash, SimpleEdit, SimpleListEdit, BusinessHours,  gampConfig, $cordovaToast, Flash) {

    $scope.save = false;

    $scope.customer = loadedUser;

    $scope.imageUrl = loadedUser.logo ? loadedUser.logo.thumb_url : '';

    $scope.customer.isCustomer = loadedUser.roles.indexOf('customer') !== -1;

    $scope.tags = function() {
        return '#' + $scope.customer.keywords.join(' #');
    };

    $scope.hours = Object.keys(loadedUser.hours);

    $scope.options = {

        name: function(name) {
            return {
                value: name,
                title: 'Name',
                placeholder: 'edit name here',
                field: 'name'   
            };
        },

        address: function(address) {
            return {
                value: address,
                title: 'Address',
                placeholder: '# Street Name, City, Province, Postal Code',
                field: 'address'
            };
        },

        phone: function(phone) {
            return {
                value: phone,
                title: 'Phone Number',
                placeholder: 'edit phone number',
                validator: function(data) {
                    return /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/.test(data);
                },
                error: 'This is not a phone number',
                field: 'phone'
            };
        },

        email: function(email) {
            return {
                value: email,
                title: 'Email',
                placeholder: 'edit email',
                validator: function(data) { 
                    return /\S+@\S+\.\S+/.test(data);
                },
                error: 'This is not a email address',
                field: 'email'
            };
        },

        description: function(description) {
            return {
                value: description,
                title: 'Description',
                placeholder: 'edit description',
                field: 'description'
            };
        }

    };

    $scope.editValue = function(params) {
        
        SimpleEdit.init($scope, params, function(value) {
            $scope.customer[params.field] = value;
            $scope.save = true;
        }).then(function() {
            SimpleEdit.show();
        });

        return false;
    };

    $scope.editHours = function() {
        BusinessHours.init($scope, {

            hours: loadedUser.hours

        }, function(hours) {

            $scope.customer.hours = hours;

        }).then(function() {
            BusinessHours.show();
        });
    };

    $scope.editKeywords = function() {
        SimpleListEdit.init($scope, 
            {
                title: 'Edit Keywords',
                list: $scope.customer.keywords.map(function(k) { return { name: '# ' + k, value: k }; })
            }, 
            // when a new keyword is to add
            function(newItem) {
                return $scope.customer.$addTag({ keyword: newItem }).then(function() {
                    $scope.customer.keywords.push(newItem);
                    return { name: '# ' + newItem, value: newItem };
                });
            },
            // when a keyword is to delete
            function(itemToRemove) {
                return $scope.customer.$deleteTag({ keyword: itemToRemove }).then(function() {
                    $scope.customer.keywords = $scope.customer.keywords.filter(function(key){
                        return itemToRemove !== key;
                    });
                    return itemToRemove;
                });
            })
        .then(function() {
            SimpleListEdit.show();
        });
    };

    $scope.update = function() {

        var msg = false;
        if ($scope.customer.isCustomer) {
            if ($scope.customer.address === null || $scope.customer.address.length < 5)
                msg = 'Please type correct address';
            else if ($scope.customer.description === null || $scope.customer.description.length < 5)
                msg = 'Please type correct description';
            else if ($scope.customer.phone === null || $scope.customer.phone.length < 5)
                msg = 'Please type correct phone number';
        } else {
            $scope.customer.description = null;
        }

        if (msg) {
            Flash.setMessage(msg);
            return;
        }

        $scope.customer.$update().then(function() {
            $scope.save = false;
            $cordovaToast.showShortBottom('Updated successfully!');  
        });

    };

    $scope.getPicture = function() {
        navigator.camera.getPicture(function(imageUri) {
            
            $scope.$apply(function() {
               $scope.imageUrl = imageUri;
            });

            // http://localhost:3000
            var promise = FileUploader('logo', imageUri, gampConfig.baseUrl + '/users/' + loadedUser.id + '/logo?apitoken=' + Session.session.apitoken);
            
            promise.then(function(data) {

                $cordovaToast.showShortBottom('Profile photo has been uploaded successfully!');

            }, function(err) {

                Flash.setMessage('Failed to upload photo, please try agin!');
                
            });

        }, function(err) {
            
            // Flash.setMessage('failed to select photo');

        }, {
            quality: 50,
            destinationType: Camera.DestinationType.FILE_URI,
            sourceType: Camera.PictureSourceType.PHOTOLIBRARY,
            encodingType: Camera.EncodingType.JPEG,
            allowEdit: true
        });
    };

})

.controller('PromotionCtrl', function($ionicSideMenuDelegate, $rootScope, $scope, $injector, $state, MapImg, $ionicHistory, loadedPromotion, Auth, MakeReview, Review, EditPromotion, $ionicActionSheet,  $cordovaSocialSharing, $cordovaToast, $cordovaDialogs, SimpleEdit, TrackService) {
    $scope.lang = $injector.get('englishLang');

    $rootScope.$on('$ionicView.beforeEnter', function(e, data){
        $scope.isBackButtonShown = data.enableBack;
    });

    // toggleLeft menus
    $scope.toggleLeft = function() {
        $ionicSideMenuDelegate.toggleLeft();
    };

    Auth.onLoggedIn(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = Auth.owns(loadedPromotion.customer.id) || Auth.isAuthorized('admin');
    });

    Auth.onLoggedOut(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = false;
    }); 

    $scope.editiable = Auth.owns(loadedPromotion.customer.id) || Auth.isAuthorized('admin');

    $scope.promotion = loadedPromotion;

    $scope.customer = loadedPromotion.customer;

    $scope.mapurl = new MapImg().center($scope.customer.address).zoom(17).size(1000, 300).markers('red', 'S', $scope.customer.address).get();

    $scope.navigate = function() {
        launchnavigator.navigate(
          loadedPromotion.customer.address,
          null,
          function(){
            
          },
          function(error){
            
          },
          {
            preferGoogleMaps: true,
            enableDebug: true
        });
    };

    $scope.edit = function() {
        EditPromotion.init($scope, {
            title: 'Edit Promotion',
            promotion: loadedPromotion
        }, function(deal) {
            deal.$update();
            return false;
        }).then(function() {
            EditPromotion.show();
        }); 
    };

    $scope.review = function() {
        MakeReview.init($scope, {
            rating: 0
        }, function(rating, comment) {

            $scope.promotion.$rate({ rating: rating }).then(function(res) {
                
                $scope.promotion.rating = res.rating;
                $scope.promotion.rates = res.rates;
                $cordovaToast.showShortBottom('Rated successfully!');
                // return !!comment && !!comment.length;

            }).finally(function(arg) {

                if (!comment || !comment.length) 
                    return;

                var review = new Review();
                review.review = {
                    body: comment,
                    promotion_id: $scope.promotion.id
                };
                review.$save().then(function() {
                    $cordovaToast.showShortBottom('Commented successfully!');
                });

            });

        })
        .then(function() {
            MakeReview.show();
        });
    };

    $scope.share = function() {
        $cordovaSocialSharing
            .share('Share the latest Deal from ' + $scope.customer.name + ': ' + loadedPromotion.title + ' --- ' + loadedPromotion.description + '[From Vicinity Deals]', '', loadedPromotion.customer.logo.thumb_url, loadedPromotion.url + '?format=html'  )
            // .share(loadedPromotion.title + ': ' + loadedPromotion.description, 'Promotion From [Vicinity Deals]', loadedPromotion.customer.logo.thumb_url, loadedPromotion.url)
            .then(function(result) {
               // $cordovaToast.showShortBottom('shared successfully');
               TrackService.isReady() && TrackService.track.trackEvent('share', 'deal [' + loadedPromotion.id  + ']', JSON.stringify(loadedPromotion));
            }, function(err) {
               $cordovaToast.showShortBottom('Failed! please try later.');
            });
    };

    $scope.report = function() {
        SimpleEdit.init($scope, {
            value: '',
            title: 'Report Reason',
            placeholder: 'type reason here'
        }, function(value) {
            
            loadedPromotion.$report({ reason: value }).then(function() {
                $cordovaToast.showShortBottom('Reported successfully!');
            });

        }).then(function() {
            SimpleEdit.show();
        }); 
    };

    $scope.showMoreMenu = function() {
        var buttons = [
            {
                text: 'Show Reviews',
                icon: 'icon ion-ios-chatboxes-outline',
                action: function() {
                    $state.go('app.comments', { promotion_id: $scope.promotion.id })
                }
            },
            {
                text: 'Edit',
                icon: 'icon ion-edit',
                action: function() {
                    $scope.edit();
                }
            }
        ];

        $scope.editiable && buttons.push({
            text: 'Send Notifications',
            icon: 'icon ion-android-notifications-none',
            action: function() {
                loadedPromotion.$notify().then(function() {
                    $cordovaDialogs.alert('Your notification request has been made successfully, we will contact you shortly.', 'Success', 'OK');
                });
            }
        });

        Auth.isAuthorized('admin') && buttons.push({
            text: 'Approve',
            icon: 'icon ion-checkmark-round',
            action: function() {
                loadedPromotion.$approve().then(function() {
                    $cordovaToast.showShortBottom('Approved successfully!');
                });
            }
        });

        Auth.isAuthorized('admin') && buttons.push({
            text: 'Reject',
            icon: 'icon ion-close-round',
            action: function() {
                SimpleEdit.init($scope, {
                    value: '',
                    title: 'Rejection Reason',
                    placeholder: 'type reason here'
                }, function(value) {
                    
                    loadedPromotion.$reject({ reason: value }).then(function() {
                        $cordovaToast.showShortBottom('Rejected successfully!');
                    });

                }).then(function() {
                    SimpleEdit.show();
                });
            }
        });

        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent))
                    return buttons.map(function(b) { b.text = '<i class="'+ b.icon +'"></i>' + b.text; return b; });
                else
                    return buttons;
            }(),
            titleText:  'Options',
            cancelText: 'Cancel',
            destructiveText: 'Delete',
            buttonClicked: function(index) {
                buttons[index].action();
                return true;
            },
            destructiveButtonClicked: function() {
                loadedPromotion.$delete().then(function() {
                    $cordovaToast.showShortBottom('Deleted successfully!');
                    $ionicHistory.goBack(-1);
                });
            }
        });
    };
})

.controller('CommentsCtrl', function($scope, Review, $state) {

    $scope.comments = [];

    $scope.page = 1;

    $scope.per_page = 20;

    $scope.params = $state.params;

    $scope.hideInfiniteScroll = true;

    $scope.loadNext = function() {

        $scope.params.page = $scope.page;
        $scope.params.per_page = $scope.per_page;
        $scope.params.sortBy = 'created_at';

        return Review.query($scope.params).$promise.then(function(comments) {
            $scope.hideInfiniteScroll = false;
            $scope.page ++;
            $scope.comments = $scope.comments.concat(comments);
            if(comments.length < $scope.per_page) {
                $scope.hideInfiniteScroll = true;
            }
            $scope.$broadcast('scroll.infiniteScrollComplete');
        }, function() {
            $scope.$broadcast('scroll.infiniteScrollComplete');
        });
    };

    $scope.loadNext();

})

// Promotion List Controller
.controller('PromotionsCtrl', function($scope, $state, $localstorage, loadedUser, EditPromotion, Promotion, Auth, Session, PromotionFilter, $ionicActionSheet, $cordovaToast) {

    Auth.onLoggedIn(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = Auth.owns($state.params.customer_id) || Auth.isAuthorized('admin');
    });

    Auth.onLoggedOut(function() {
        // set profile as editiable, if user owns this or user's role is admin
        $scope.editiable = false;
    }); 
    
    $scope.promotions = [];

    $scope.customer = loadedUser;

    $scope.hideInfiniteScroll = true;

    $scope.editiable = Auth.owns($state.params.customer_id) || Auth.isAuthorized('admin');

    $scope.page = 1;

    $scope.per_page = 10;

    $scope.params = {};

    $scope.loadNext = function() {
        $scope.params.page = $scope.page;
        return Promotion.query($scope.params).$promise.then(function(promotions) {
            $scope.hideInfiniteScroll = false;
            $scope.page ++;
            $scope.promotions = $scope.promotions.concat(promotions);
            if(promotions.length < $scope.per_page) {
                $scope.hideInfiniteScroll = true;
            }
            $scope.$broadcast('scroll.infiniteScrollComplete');
        }, function() {
            $scope.hideInfiniteScroll = true;
            $scope.$broadcast('scroll.infiniteScrollComplete');
        });
    };

    $scope.new = function() {
        var promotion = new Promotion();
        EditPromotion.init($scope, {
            title: 'New Promotion',
            promotion: promotion
        }, function(deal) {
            deal.$save({ user_id: $state.params.customer_id }).then(function() {
                $cordovaToast.showShortBottom('promotion created successfully');
                EditPromotion.hide();
                EditPromotion.remove();
            });
            return false;
        }).then(function() {
            EditPromotion.show();
        });
    };

    $scope.refresh = function() {
        var settings = $localstorage.getObject('promotionFilterSettings');
        var params = $state.params;
        params.sortBy = settings.sortBy || 'created_at';
        params.status = '';
        if (!$scope.editiable) 
            params.expire_at = '>' + new Date().toString();
        if ($scope.editiable && settings.submitted !== false)
            params.status += 'submitted,,';
        if ($scope.editiable && settings.reviewed !== false)
            params.status += 'reviewed,,';
        if ($scope.editiable && settings.rejected !== false)
            params.status += 'rejected';
        if (!$scope.editiable)
            delete params.status;

        $scope.promotions = [];
        $scope.page = 1;
        $scope.params = params;
        $scope.params.page = $scope.page;
        $scope.params.per_page = $scope.per_page;
        $scope.params.customer_id = loadedUser.id;

        return $scope.loadNext().then(function() {
            $scope.$broadcast('scroll.refreshComplete');
        }, function() {
            $scope.$broadcast('scroll.refreshComplete');
        });
    };

    $scope.openFilter = function() {
        PromotionFilter.init($scope, $scope.editiable, function(settings) {

        }).then(function() {
            PromotionFilter.show();
        });
    };

    $scope.showMoreMenu = function() {
        var buttons = [
            {
                text: 'Refresh',
                icon: 'icon ion-ios-reload',
                action: $scope.refresh
            }
        ];

        $scope.editiable && buttons.push({
            text: 'New Promotion',
            icon: 'icon ion-plus',
            action: $scope.new
        });

        $ionicActionSheet.show({
            buttons: function() {
                if(/Android/.test(navigator.userAgent))
                    return buttons.map(function(b) { b.text = '<i class="' + b.icon + '"></i>' + b.text; return b; });
                else
                    return buttons;
            }(),
            titleText:  'Options',
            cancelText: 'Cancel',
            buttonClicked: function(index) {
                buttons[index].action();
                return true;
            },
        });
    };

    // initialize
    $scope.refresh();

})

// login controller, handles login operations
.controller('LoginCtrl', function($scope, $injector, Auth, User, $state, $location, $localstorage, Notification, $cordovaDialogs, Flash) {
    $scope.lang = $injector.get('englishLang');

    var emailTester = /\S+@\S+\.\S+/;

    $scope.cancel = function() {
        $state.go('app.search');
    };

    // reset the password
    $scope.reset = function() {
        $cordovaDialogs.confirm('Are you sure?', 'Confirm', ['Sure', 'No']).then(function(index) {
            if (index === 1 && emailTester.test($scope.credentials.email || 'none')) {
              User.query({
                email: $scope.credentials.email
              }).$promise.then(function(data) {
                if(!data[0]) {
                    Flash.setMessage('user does not exist');
                } else {
                    data[0].$reset().then(function() {
                       $cordovaDialogs.alert('You have successfully made a password reset request, we will contact you shortly.', 'Success', 'OK'); 
                    });
                }
              });
            } 
        });
    };

    // credentails used to login
    $scope.credentials = {};

    // on email change,
    // autocomplete password if logged in before
    $scope.onEmailChange = function() {
        // alert($scope.credentials.email);
        var savedUsers = $localstorage.getObject('savedUsers');
        if (savedUsers[$scope.credentials.email]) {
            $scope.credentials.password = savedUsers[$scope.credentials.email].password;
        }
    };
    
    // login
    $scope.login = function() {
        // set up credentials 
        Auth.setCredentials($scope.credentials.email, $scope.credentials.password);
        // attempt to login
        Auth.login().then(function(data) {

            // save the credentials
            var savedUsers = $localstorage.getObject('savedUsers');
            data.user.password = $scope.credentials.password;
            savedUsers[$scope.credentials.email] = data.user;
            $localstorage.setObject('savedUsers', savedUsers);

            // get push notification info
            var devicePushInfo = $localstorage.getObject('devicePushInfo');

            // update the user_id to the device record stored on the server
            if (devicePushInfo.identity) {
                Notification.createDevice(
                    devicePushInfo.identity,
                    devicePushInfo.token,
                    devicePushInfo.os,
                    data.user.id
                );
            }

            // // get confirmed and submitted
            // data.user.roles.indexOf('customer') === -1 && $cordovaDialogs.confirm('To become a business user and be able to push your lastet deals to the users in your area? Please fill up the form required in profile page.', 'Become A Business User', ['Go', 'Later']).then(function(index) {
            //     if (index === 1) {
            //         $state.go('app.profile-edit', { userid: data.user.id });
            //     }
            //     // jump to the original url if provided
            //     else if($state.params.jump_to) {
            //         $location.path($state.params.jump_to);
            //     } else {
            //         $state.go('app.profile', { userid: data.user.id });
            //     }
            // });

            // if (data.user.roles.indexOf('customer') !== -1) {
            if($state.params.jump_to) {
                $location.path($state.params.jump_to);
            } else {
                $state.go('app.profile', { userid: data.user.id });
            }
            // }

        });
    };

})

// login as ...
// If several users have loggedin before on this phone, then list them
// on this page
.controller('LoginasCtrl', function($scope, Auth, $state, $localstorage) {

    var savedUsers = $localstorage.getObject('savedUsers');

    $scope.users = [];

    for (var key in savedUsers) {
        $scope.users.push(savedUsers[key]);
    }

    $scope.loginAs = function(user) {
        Auth.setCredentials(user.email, user.password);
        Auth.login().then(function(data) {

            var savedUsers = $localstorage.getObject('savedUsers');
            data.user.password = user.password;
            savedUsers[data.user.email] = data.user;
            $localstorage.setObject('savedUsers', savedUsers);

            $state.go('app.search');
        }, function(err) {

            if (err.code !== 500) {
                var savedUsers = $localstorage.getObject('savedUsers');
                delete savedUsers[user.email];
                $localstorage.setObject('savedUsers', savedUsers);
                $scope.users = savedUsers;
            }

            $state.go('app.search');
        });
    };

    // go to search page, if there is no logged in user saved
    $scope.users.length === 0 && $state.go('app.search');

})

// signup controller, handles signup operations
.controller('SignupCtrl', function($scope, $injector, Auth, $state, Flash, $ionicHistory, $cordovaDialogs) {
    $scope.lang = $injector.get('englishLang');

    // user to be registered
    $scope.user = {};
    $scope.signup = function() {
        Auth.signupWithEmail({ user: $scope.user }).then(function(data) {
            $ionicHistory.goBack();
            $cordovaDialogs.alert('Welcome to Vicinity Deals! You may now login and customize your profile. Thank you.', 'Success', 'OK'); 
        });
    };
})

// signup controller, handles signup operations
.controller('StoreCtrl', function($scope, $state, Session, Subscription, $cordovaToast, $ionicSideMenuDelegate, $cordovaDialogs) {

    $scope.subscriptions = [];

    $scope.products = [];

    // get all subscriptions
    Subscription.query({
        user_id: Session.user().id,
        sortBy: 'status', 
        status: 'activated,,expired' // only activated and expired ones will be returned
    }).$promise.then(function(subcriptions) {
        $scope.subscriptions = subcriptions;
    });

    // get currently aviliable products
    Subscription.products().$promise.then(function(products) {
        $scope.products = products;
    });

    // perform a membership request
    $scope.makeRequest = function(product_id) {

        // get a new subscription
        var subscription = new Subscription();

        // set its product id
        subscription.product_id = product_id;
        // set its user id
        subscription.user_id = Session.user().id;

        // get confirmed and submitted
        $cordovaDialogs.confirm('Are you sure?', 'Confirm', ['Sure', 'No']).then(function(index) {
            if (index === 1) {
                subscription.$save().then(function() {
                    $cordovaDialogs.alert('Your request for membership has been successfully sent, we will contact you shortly.', 'Success', 'OK'); 
                });
            } 
        });
    };

        // toggleLeft menus
    $scope.toggleLeft = function() {
        $ionicSideMenuDelegate.toggleLeft();
    };

});