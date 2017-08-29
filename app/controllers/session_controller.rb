class SessionController < ApplicationController
    skip_before_action :verify_authenticity_token

	def new
	end

    def create
        puts "ok1"
        puts params[:session]
        puts "ak1"

		user = User.find_by_email(params[:session][:email])
		# If the user exists AND the password entered is correct.
		if user && user.authenticate(params[:session][:password])
			# Save the user id inside the browser cookie. This is how we keep the user
			# logged in when they navigate around our website.
            session[:user_id] = user.id
            @current_user = user
			render json: {:status => 200, :data => {
                token:              user.auth_token,
                remoteAuthorized:   user.remote_id != nil
            }}

            puts @current_user
            puts session[:user_id]
            @current_user
		else
			# If user's login doesn't work, send them back to the login form.
			render :json => {:error => "login or password are incorrect"}, :status => 404
		end
	end

	def destroy
		session[:user_id] = nil
		render json: {:status => 200}
	end
end
