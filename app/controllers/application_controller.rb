class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :null_session
    helper_method :current_user

    def current_user
        puts "lol11"
        puts session[:user_id]
        puts "lol22"
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def authorize
		render json: {:status => 401, :data => {error: "user is unauthorized"}} unless current_user
	end
end
