angular.module('starter.authenticaion',[])

.factory('Auth', function(gampConfig, $http, Session) {

	var login_callbacks = [];
	var logout_callbacks = [];

	var credentials = {
		email:    'arjun@ibm.com',
		password: 'root'
	};

	return {

		setCredentials: function(email, pass) {
			credentials.email = email;
			credentials.password = pass;
		},

		token: function() {
			return Session.session.apitoken;
		},

		// check if user is authenticated
		isLoggedin: function() {
			return !!Session.session && !!Session.session.apitoken;
		},

		owns: function(userid) {
			return this.isLoggedin() && Session.session.user.id === userid;
		},

		// check if user is authorized
		isAuthorized: function(authorizedRoles) {
			if (!angular.isArray(authorizedRoles)) {
				authorizedRoles = [authorizedRoles];
			}

			return this.isLoggedin() && Session.session.user.roles.filter(function(r) {
				return authorizedRoles.indexOf(r) !== -1;
			}).length > 0;
		},

		logout: function() {
			return $http.post([gampConfig.baseUrl, gampConfig.signout].join('/'))
					.then(function(res) {
						logout_callbacks.forEach(function(cb) {
							cb();
						});
						Session.destory();
						return res.data;
					});
		},

		login: function() {
			return $http.post([gampConfig.baseUrl, gampConfig.emailSignin].join('/'), credentials)
					.then(function(res) {
						Session.create(res.data);
						login_callbacks.forEach(function(cb) {
							cb(res.data);
						});
						return res.data;
					});
		},

		signupWithEmail: function(user) {
			return $http.post([gampConfig.baseUrl, gampConfig.signupWithEmail].join('/'), user)
					.then(function(res) {
						return res.data;
					});
		},

		signout: function() {
			Session.destory();
			logout_callbacks.forEach(function(cb) {
				cb();
			});
		},

		onLoggedIn: function(callback) {
			login_callbacks.push(callback);
		},

		onLoggedOut: function(callback) {
			logout_callbacks.push(callback);
		} 
	};

})

// a singleton object, to keep user's session information
.service('Session', function($localstorage) {

	this.reload = function() {
		this.session = $localstorage.getObject('savedSession');
		this.valid() || this.destory();	
		console.log('[SESSION][RELOADED]', this.session.apitoken, this.user().name);	
	};

	this.valid = function() {
		return this.session.expire_at && new Date(this.session.expire_at) > new Date();
	};

	// create a session
	this.create = function(session) {
		this.session = session;
		$localstorage.setObject('savedSession', session);
	};

	// destory the session
	this.destory = function() {
		$localstorage.setObject('savedSession', {});
		this.session = null;
		console.log('[SESSION][DELETED]');
	};

	// logged in user,
	// return {} if no session created
	this.user = function() {
		if (this.session) {
			return this.session.user;
		}
		return {};
	};

	return this;
});