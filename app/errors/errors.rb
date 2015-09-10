# here is the module defines all handleable erros
module Errors

	# here defines the general error class
	class GampError < Exception

		# constructor
		def initialize(code, message)
			@code = code
			@error = message
		end

		def status
			@code
		end

		def error
			@error
		end

		def to_hash
			{
				code: status,
				error: error 
			}
		end

		# convert error to json 
		def to_json(*)
			to_hash.to_json
		end

	end

	# in some cases, when error happens, we want to return an empty list instead of an error message
	class EmptyList < Exception
		def initialize
			@code = 200
			@msg = 'nothing found'
		end
	end

	class BadRequestError < GampError
		def initialize(message)
			@code = 400
			@error = message
		end
	end

	class NotauthorizedError < GampError
		def initialize
			@code = 403
			@error = 'you are not authorized'
		end
	end

	# Unauthenticated error
	class UnauthenticatedError < GampError
		def initialize
			@code = 401
			@error = 'valid credential required to preform this action.'
		end
	end

	# mongodid error
	class UnprocessableEntityError < GampError
		def initialize(fields)
			@code = 422
			@error = 'the request contains unprocessable entities.'
			@fields = fields
			puts fields.to_yaml
		end

		def fields
			@fields
		end

		def to_hash
			{
				code: status,
				error: error,
				fields: @fields.to_hash
			}
		end
	end

	# routing error
	class RoutingError < GampError
		def initialize(path)
			@code = 404
			@error = 'the resource requested: \'' + path + '\' could not be found.'
		end
	end

	# not found error
	class NotfoundError < GampError
		def initialize(classname, query)
			@code = 404
			@error =  classname + ': \'' + query + '\' could not be found.'
		end
	end

	#  
	class DuplicateError < GampError
		def initialize(message)
			@code = 409
			@error = message
		end
	end

	# internal server msssage.
	# devmessage should not be shown to users
	class InternalError < GampError
		def initialize(message)
			@code = 500
			@error = 'oops! something went wrong on server.'
			@devmessage = message
			puts message
		end

		def to_hash
			hash = self.class.superclass.instance_method(:to_hash).bind(self).call
			# hash[:devmessage] = @devmessage
			hash
		end
	end

end