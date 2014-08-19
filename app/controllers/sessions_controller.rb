class SessionsController < ApplicationController
	def new
	end

	def create
		user = User.find_by_name(params[:name])

		if user && user.authenticate(params[:password])
			sign_in user
			redirect_back_or root_path   # friendly forwarding or redirect to root_path
		else
			flash.now[:error] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to root_url
	end
end
