angular.module('starter.config', [])

// constant gampConfig is used to define all 
// app config parameters
.constant('gampConfig', {

	// baseUrl: 'http://192.168.250.6:3000',
	
	baseUrl: 'http://rails-api-env-b4cm2bfxbr.elasticbeanstalk.com',
	
	// baseUrl: 'http://vicinity-deals-test-3hqca6tun5.elasticbeanstalk.com',
	
	// baseUrl: 'http://localhost:3000',
	
	googleAnalyticsID: 'UA-66194905-1',

	promotions: 'promotions',

	subscriptions: 'subscriptions',

	users: 'users',

	catagorys: 'catagorys',

	reviews: 'reviews',

	devices: 'devices',

	emailSignin: 'signin',

	signout: 'signout',

	signupWithEmail: 'signup',

	mapImgUrl: 'https://maps.googleapis.com/maps/api/staticmap?',

	singleSelectTemplateUrl: 'templates/models/single-select.html',

	editPromotionTemplateUrl: 'templates/models/edit-deal.html',

	simpleEditTemplateUrl: 'templates/models/simple-edit.html',

	simpleListEditTemplateUrl: 'templates/models/simple-list-edit.html',

	makeReviewTemplateUrl: 'templates/models/review.html',

	promotionFilterTemplateUrl: 'templates/models/promotion-filter.html',

	newPasswordTemplateUrl: 'templates/models/new-password.html',

	businessHoursScopeTemplateUrl: 'templates/models/edit-hours.html',

	loadingInterceptorMatchers: [
		'.*/signin.*',
		'.*/users.*',
		'.*/search.*',
		'.*/reviews.*',
		'.*/catagorys.*',
		'.*/promotions.*',
		'.*/subscriptions.*'
	]

});