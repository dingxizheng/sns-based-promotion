angular.module('starter.models', [])

.factory('SingleSelect', function($ionicModal, gampConfig) {

    var singleModal = null;

    return {

        init: function(scope, params, onSave) {

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

            return $ionicModal.fromTemplateUrl(gampConfig.singleSelectTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})

// 
.factory('EditPromotion', function($ionicModal, Catagory, SingleSelect, gampConfig, $filter) {

    var singleModal = null;
    var unwatch = function() {};
    var catagorys = [];

    return {

        init: function(scope, params, onSave) {

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
                catagory: params.promotion.catagory && params.promotion.catagory.name || 'None',
                catagorys: catagorys,
                saveable: false,

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

                cancel: function() {
                    // unwatch();
                    self.hide();
                    self.remove();
                },

                save: function(promotion) {
                    if (onSave(promotion)) {
                        // unwatch();
                        self.remove();
                    }
                }

            };

            // watch promotion 
            unwatch = scope.$watch('editPromotionScope.promotion', function(newVal, oldVal) {
                scope.editPromotionScope.saveable = true;
            }, true);

            // return a promise which will be resolved with the model
            return $ionicModal.fromTemplateUrl(gampConfig.editPromotionTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            unwatch();
            singleModal.remove();
        }

    };

})

.factory('NewPassword', function($ionicModal, gampConfig) {

    var singleModal = null;

    return {

        init: function(scope, onSave) {

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

            // return a promise which will be resolved with the model
            return $ionicModal.fromTemplateUrl(gampConfig.newPasswordTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})


.factory('SimpleEdit', function($ionicModal, gampConfig, Flash) {

    var singleModal = null;

    return {

        init: function(scope, params, onSave) {

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

            return $ionicModal.fromTemplateUrl(gampConfig.simpleEditTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})


.factory('SimpleListEdit', function($ionicModal, SimpleEdit, gampConfig) {

    var singleModal = null;

    return {

        init: function(scope, params, onAdd, onDelete) {

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

            return $ionicModal.fromTemplateUrl(gampConfig.simpleListEditTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})

.factory('MakeReview', function($ionicModal, gampConfig) {

    var singleModal = null;
    var unwatch = function() {};

    return {

        init: function(scope, params, onSave) {

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
            unwatch = scope.$watch('makeReviewScope.rating', function(newVal, oldVal) {
                scope.makeReviewScope.saveable = true;
            }, true);


            return $ionicModal.fromTemplateUrl(gampConfig.makeReviewTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            unwatch();
            singleModal.remove();
        }

    };

})

.factory('BusinessHours', function($ionicModal, gampConfig, SingleSelect) {

    var singleModal = null;

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

    return {

        init: function(scope, params, onSave) {

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


            return $ionicModal.fromTemplateUrl(gampConfig.businessHoursScopeTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})

.factory('PromotionFilter', function($ionicModal, gampConfig, $localstorage) {

    var singleModal = null;

    return {

        init: function(scope, editiable, onChange) {

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


            return $ionicModal.fromTemplateUrl(gampConfig.promotionFilterTemplateUrl, {
                scope: scope,
                animation: 'slide-in-up'
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

})


.factory('AutoSuggest', function($http, $ionicModal, gampConfig) {

    var singleModal = null;

    return {

        init: function(scope, params, onDone) {

            var self = this;

            var cache = {};

            scope.autoSuggestScope = {

                query: params.query || '',

                terms: [],

                onChange: function() {
                    console.log('search', gampConfig.baseUrl + '/suggest?query=' + scope.autoSuggestScope.query);
                    cache[scope.autoSuggestScope.query] || $http.get(gampConfig.baseUrl + '/suggest', {
                        params: {
                            query: scope.autoSuggestScope.query
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

            scope.$watch('autoSuggestScope.query', function(newvalue, oldvalue) {
                newvalue.length > 1 && scope.autoSuggestScope.onChange();
            });


            return $ionicModal.fromTemplateUrl('templates/models/auto-suggest.html', {
                scope: scope,
                animation: 'fade-in',
                focusFirstInput: true
            }).then(function(modal) {
                scope.$on('$destroy', function() {
                    self.remove();
                });
                singleModal = modal;
            });

        },

        show: function() {
            singleModal.show();
        },

        hide: function() {
            singleModal.hide();
        },

        remove: function() {
            singleModal.remove();
        }

    };

});
