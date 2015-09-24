angular.module('starter.models', [])

.factory('BaseModal', function($ionicModal) {

    return {

        _modal: null,

        _unwatchFns: [],

        _create: function(template, scope, animation) {
            var self = this;
            return $ionicModal.fromTemplateUrl(template, {
                scope: scope,
                animation: animation || 'slide-in-up',
                focusFirstInput: true
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                self._modal = modal;
            });
        },

        show: function() {
            this._modal.show();
        },

        hide: function() {
            this._modal.hide();
        },

        remove: function() {
            this._unwatchFns.forEach(function(fn){ fn() });
            this._modal.remove();
        }

    };

})

.factory('SingleSelect', function(BaseModal, gampConfig) {

    var singleSelect = Object.create(BaseModal);

    singleSelect.init = function(scope, params, onSave) {

        var self = this;

        scope.singleSelectScope = {

            list: params.list,
            selected: params.selected || 'none',
            saveable: false,
            title: params.title || 'Select One',

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function(value) {
                onSave(value);
                self.remove();
            },

            onchange: function() {
                scope.singleSelectScope.saveable = false;
                if (scope.singleSelectScope.selected !== params.selected) {
                    scope.singleSelectScope.saveable = true;
                }
                return true;
            }

        };

        return self._create(gampConfig.singleSelectTemplateUrl, scope);
    };

    return singleSelect;

})

// 
.factory('EditPromotion', function(BaseModal, FileUploader, Session, Catagory, SimpleListEdit, Flash, SingleSelect, gampConfig, $filter, $q) {

    var editPromotion = Object.create(BaseModal);
    var catagorys = [];

    editPromotion.init = function(scope, params, onSave) {

        params.promotion.keywords || (params.promotion.keywords = []);

        catagorys.length === 0 && Catagory.query().$promise.then(function(catagorys_) {
            catagorys = catagorys_;
        });

        var self = this;

        var today = new Date();

        if (params.promotion.expire_at)
            params.promotion.expire_at = new Date(params.promotion.expire_at);
        else
            params.promotion.expire_at = new Date(today.setDate(today.getDate() + 7));

        if (params.promotion.start_at)
            params.promotion.start_at = new Date(params.promotion.start_at);
        else
            params.promotion.start_at = new Date();

        scope.editPromotionScope = {

            title: params.title,
            promotion: params.promotion,
            catagory: params.promotion.catagory && params.promotion.catagory.name || '',
            catagorys: catagorys,
            keywords: params.promotion.keywords.length > 0 ? '#' + params.promotion.keywords.join(' #') : '',
            saveable: false,

            valueChanged: function() {
                this.saveable = true;
            },

            addCover: function() {
                navigator.camera.getPicture(function(imageUri) {          
                    
                    // $scope.$apply(function() {
                    //    $scope.imageUrl = imageUri;
                    // });

                    var promise = FileUploader('image', imageUri, gampConfig.baseUrl + '/images?apitoken=' + Session.session.apitoken);
                    
                    promise.then(function(data) {
                        // set customer's logo_id when the new image was successfully uploaded.
                        params.promotion.cover_id = JSON.parse(data.response).id;
                        params.promotion.cover = JSON.parse(data.response);
                        scope.editPromotionScope.valueChanged();
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
            },

            selectCatagory: function() {

                SingleSelect.init(scope, {
                            list: catagorys.map(function(item) {
                                return {
                                    name: item.name,
                                    value: item.id
                                }
                            }),
                            selected: scope.editPromotionScope.promotion.catagory_id
                        },
                        function(value) {
                            scope.editPromotionScope.valueChanged();
                            scope.editPromotionScope.promotion.catagory_id = value;
                            scope.editPromotionScope.catagory = catagorys.filter(function(item) {
                                return value === item.id
                            })[0].name;
                        })
                    .then(function() {
                        scope.$on('$destroy', function() {
                            self.remove();
                        });
                        SingleSelect.show();
                    });

            },

            editKeywords: function() {
                SimpleListEdit.init(scope, 
                    {
                        title: 'Edit Keywords',
                        list: params.promotion.keywords.map(function(k) { return { name: '# ' + k, value: k }; })
                    }, 
                    // when to add a keyword
                    function(newItem) {
                        if (params.promotion.keywords.indexOf(newItem) != -1) {
                            Flash.setMessage('cannot add a duplicate keyword');
                        } else {
                            var deferred = $q.defer();
                            params.promotion.keywords.push(newItem);
                            scope.editPromotionScope.keywords = params.promotion.keywords.length > 0 ? '#' + params.promotion.keywords.join(' #') : '';
                            deferred.resolve({ name: '# ' + newItem, value: newItem });
                            scope.editPromotionScope.valueChanged();
                            return deferred.promise;
                        }
                    },
                    // when to delete a keyword
                    function(itemToRemove) {
                        var deferred = $q.defer();
                        params.promotion.keywords = params.promotion.keywords.filter(function(key) { return itemToRemove !== key });
                        scope.editPromotionScope.keywords = params.promotion.keywords.length > 0 ? '#' + params.promotion.keywords.join(' #') : '';
                        deferred.resolve(itemToRemove);
                        scope.editPromotionScope.valueChanged();
                        return deferred.promise;
                    })
                .then(function() {
                    SimpleListEdit.show();
                });
            },

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function(promotion) {
                onSave(promotion).then(function() {
                    scope.editPromotionScope.saveable = false;
                    self.remove();
                });
            }

        };

        return self._create(gampConfig.editPromotionTemplateUrl, scope);
    };

    return editPromotion;

})

.factory('NewPassword', function(BaseModal, gampConfig) {

    var newPassword = Object.create(BaseModal);

    newPassword.init = function(scope, onSave) {

        var self = this;

        scope.newPasswordScope = {

            cancel: function() {
                // unwatch();
                self.hide();
                self.remove();
            },

            save: function() {

                if (onSave(scope.newPasswordScope.current_password, scope.newPasswordScope.new_password)) {
                    // unwatch();
                    self.remove();
                }
            }

        };

        return self._create(gampConfig.newPasswordTemplateUrl, scope);
    };

    return newPassword;

})


.factory('SimpleEdit', function(BaseModal, gampConfig, Flash) {

    var simpleEdit = Object.create(BaseModal);

    simpleEdit.init = function(scope, params, onSave) {

        var self = this;

        scope.simpleEditScope = {

            title: params.title || 'Edit',
            value: params.value || '',
            placeholder: params.placeholder || 'type here',
            saveable: false,

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function(value) {
                if(value === null || value.length < 1 || (params.validator && !params.validator(value))) {
                    Flash.setMessage(params.error);
                } else {
                    onSave(value);
                    self.remove();
                }
            },

            onchange: function() {
                scope.simpleEditScope.saveable = false;
                if (scope.simpleEditScope.value !== params.value) {
                    scope.simpleEditScope.saveable = true;
                }
                return true;
            }

        };

        return self._create(gampConfig.simpleEditTemplateUrl, scope);
    };

    return simpleEdit;
})


.factory('SimpleListEdit', function(BaseModal, SimpleEdit, gampConfig) {

    var simpleListEdit = Object.create(BaseModal);

    simpleListEdit.init = function(scope, params, onAdd, onDelete) {

        var self = this;

        scope.simpleListEditScope = {

            title: params.title || 'Edit List',
            list: params.list || [],

            cancel: function() {
                self.hide();
                self.remove();
            },

            addItem: function() {
                // onAdd(value);
                SimpleEdit.init(scope, {
                    title: 'New Item',
                    value: '',
                    placeholder: 'add new item here'

                }, function(value) {

                    onAdd(value).then(function(item) {
                        scope.simpleListEditScope.list.push(item);
                    });

                }).then(function() {
                    SimpleEdit.show();
                });
            },

            deleteItem: function(value) {
                onDelete(value).then(function() {
                    scope.simpleListEditScope.list = scope.simpleListEditScope.list.filter(function(i) {
                        return i.value !== value;
                    });
                });
            }

        };

        return self._create(gampConfig.simpleListEditTemplateUrl, scope);
    };

    return simpleListEdit;
})

.factory('MakeReview', function(BaseModal, gampConfig) {

    var makeReview = Object.create(BaseModal);

    makeReview.init = function(scope, params, onSave) {

        var self = this;

        scope.makeReviewScope = {

            rating: params.rating || 0,
            saveable: false,

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function(rating, comment) {
                onSave(rating, comment)
                self.remove();
            }

        };

        // watch promotion 
        var unwatch = scope.$watch('makeReviewScope.rating', function(newVal, oldVal) {
            scope.makeReviewScope.saveable = true;
        }, true);

        self._unwatchFns.push(unwatch);

        return self._create(gampConfig.makeReviewTemplateUrl, scope);
    }

    return makeReview;

})

.factory('BusinessHours', function(BaseModal, gampConfig, SingleSelect) {

    var businessHours = Object.create(BaseModal);

    var selections = [];

    for (var i = 0; i < 25; i ++) {
        selections.push({
            name: i + ':00',
            value: i + ':00'
        });
        i !== 24 && selections.push({
            name: i + ':30',
            value: i + ':30'
        });
    } 

    var days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ];

    businessHours.init = function(scope, params, onSave) {

        var self = this;

        scope.businessHoursScope = {

            hours: params.hours || {},

            days: days,

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function(hours) {
                onSave(hours);
                self.hide();
                self.remove();
            },

            editHours: function(day) {

                SingleSelect.init(scope, {
                        list: selections,
                        selected: 25,
                        title: 'Open Hour'
                    },
                    function(value) {

                        scope.businessHoursScope.hours[day].from = value;
                        
                        SingleSelect.init(scope, {
                                list: selections,
                                selected: 25,
                                title: 'Close Hour'
                            },
                            function(value) {
                                
                                scope.businessHoursScope.hours[day].to = value;

                            })
                        .then(function() {
                            scope.$on('$destroy', function() {
                                self.remove();
                            });
                            SingleSelect.show();
                        });

                    })
                .then(function() {
                    scope.$on('$destroy', function() {
                        self.remove();
                    });
                    SingleSelect.show();
                });

            },

            buttonClick: function($event, day) {
                if ($event.target.checked && !scope.businessHoursScope.hours[day]) {
                    scope.businessHoursScope.hours[day] = {
                        from: '9:00',
                        to: '17:00'
                    };
                } 

                if (!$event.target.checked && !!scope.businessHoursScope.hours[day]) {
                    delete scope.businessHoursScope.hours[day];
                }
            }

        };

        return self._create(gampConfig.businessHoursScopeTemplateUrl, scope);
    };

    return businessHours;

})

.factory('PromotionFilter', function(BaseModal, gampConfig, $localstorage) {

    var promotionFilter = Object.create(BaseModal);

    promotionFilter.init = function(scope, editiable, onChange) {

        var self = this;
        var settings = $localstorage.getObject('promotionFilterSettings');
        settings.sortBy = settings.sortBy || 'created_at';
        settings.submitted = (settings.submitted === undefined) ? true : settings.submitted;
        settings.reviewed = (settings.reviewed === undefined) ? true : settings.reviewed;
        settings.rejected = (settings.rejected === undefined) ? true : settings.rejected;

        scope.promotionFilterScope = {
            settings: settings,
            editiable: editiable,

            cancel: function() {
                self.hide();
                self.remove();
            },

            save: function() {
                $localstorage.setObject('promotionFilterSettings', scope.promotionFilterScope.settings);
                onChange(settings);
                self.remove();
            }
        };
        return self._create(gampConfig.promotionFilterTemplateUrl, scope);
    };

    return promotionFilter;

})


.factory('AutoSuggest', function($http, BaseModal, gampConfig) {

   var autoSuggest = Object.create(BaseModal);

   autoSuggest.init = function(scope, params, onDone) {

        var self = this;

        var cache = {};

        scope.autoSuggestScope = {

            query: params.query || '',

            terms: [],

            onChange: function() {
                console.log('search', gampConfig.baseUrl + '/suggest?query=' + scope.autoSuggestScope.query);
                cache[scope.autoSuggestScope.query] || $http.get(gampConfig.baseUrl + '/suggest', {
                    params: {
                        query: scope.autoSuggestScope.query,
                        type: 'name,,keyword,,title,,catagory'
                    },
                    track: [{
                        dimension: 'suggest',
                        level: function(obj, params) { return params.query; },
                        view: 'type'
                    }], 
                    cache: true
                })
                .then(function(res) {
                   cache[res.config.params.query] = res.data;

                   if(res.config.params.query === scope.autoSuggestScope.query) {
                        scope.autoSuggestScope.terms = res.data;
                    }

                });

                if (cache[scope.autoSuggestScope.query]) {
                   scope.autoSuggestScope.terms = cache[scope.autoSuggestScope.query];
                }
            },

            select: function(term) {
               scope.autoSuggestScope.query = term; 
            },

            cancel: function() {
                self.hide();
                self.remove();
            },

            done: function() {
                onDone(scope.autoSuggestScope.query);
                self.remove();
            }
        };

        var unwatch = scope.$watch('autoSuggestScope.query', function(newvalue, oldvalue) {
            newvalue.length > 1 && scope.autoSuggestScope.onChange();
        });

        self._unwatchFns.push(unwatch);

        return self._create('templates/models/auto-suggest.html', scope, 'fade-in');
   };

    return autoSuggest;

});