class ApplicationController < ActionController::Base
	protect_from_forgery
	include SessionsHelper
	include UsersHelper

	# Force signout to prevent CSRF (cross-site request forgery) attacks
	def handle_unverified_request
		sign_out
		super
	end
end
