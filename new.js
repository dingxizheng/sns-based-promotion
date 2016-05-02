
Object.defineProperty(Object.prototype, "should", { 
	get: function () { 
		
		var d = function property(name){
			
		}.bind(this);

		return {
			have: {
				property:  d
			},
			be: {},
			not: {}
		};
	} 
});

Object.prototype.immutable = function(key, value) {
	Object.defineProperty(this, key, {
		value: Object.freeze(value)
	});
	return this;
};

 var obj = {};

 obj.immutable('name', 'ding');
 obj.name = 'not ok';

 console.log(obj.name);