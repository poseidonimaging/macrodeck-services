# The UserWebService. Provides UserService
# functions to remote via ActionWebService.

# The UserService API definition
require 'digest/sha2'

class UserServiceAPI < ActionWebService::API::Base
	api_method :get_auth_cookie, {
			:expects =>	[{ :userName	=> :string }],
			:returns => [:string]
		}
		
	api_method :get_auth_code, {
			:expects => [{ :userName	=> :string },
						 { :authToken	=> :string }],
			:returns => [:string]
		}
end

# UserWebService. Currently provides user authentication
# facilities for remote SOAP applications.
class UserWebService < ActionWebService::Base
	web_service_api UserServiceAPI
	
	# Returns an authCookie for the specified user.
	# The authCookie is a required part of the authToken,
	# which is used to get a user's authCode. The cookie
	# serves no purpose other than as a salt, really.
	def get_auth_cookie(userName)
		uuid = UserService.lookupUserName(userName)
		return UserService.generateAuthCookie(uuid)
	end
	
	# Returns the user's authCode if the token specified is valid.
	# The token is constructed as follows:
	#
	#   token = SHA512(authCookie + ":" + SHA512(salt + ":" + password))
	#
	# If there is no salt, it will look like this:
	#
	#   token = SHA512(authCookie + ":" + SHA512(password))
	#
	# The SHA512 we expect is a "hexdigest" -- i.e. it looks like a really
	# long MD5. We also expect it in lowercase.
	#
	# The salt or lack thereof is set by the website running Services.
	def get_auth_code(userName, authToken)
		logger = ActionController::Base.logger
		logger.info "UserWebService::getAuthCode called!"
		uuid = UserService.lookupUserName(userName)
		# build an authToken based on our data
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			our_token = Digest::SHA512::hexdigest(user.authcookie + ":" + user.password.split(":")[1])
			if our_token.downcase == authToken.downcase
				# All is well, the token is valid
				logger.info "#{userName} - Authentication OK! Cookie = \"#{user.authcookie}\" Token = \"#{our_token}\""
				return user.authcode
			else
				logger.info "#{userName} - Authentication Failure :(."
				logger.info "Recieved token = \"#{authToken}\" Expected token = \"#{our_token}\""
				logger.info "Cookie = \"#{user.authcookie}\""
				return nil
			end
		else
			return nil
		end
	end
end