Rails.application.routes.draw do

	get 'root/index'

	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	root 'root#js'

    post '/user/login'               => 'session#create'
    post '/user/logout'              => 'session#destroy'

    post '/user/signup'        => 'users#new'
    post '/user/info'          => 'users#get_account_info'
    post '/user/signup_remote' => 'users#new_remote'

    post '/user/update_remote'       => 'users#update_remote'

    post '/card/new'            => 'cards#new'
    post '/card/delete'         => 'cards#delete'

    post '/cards'               => 'cards#get'

	post '/card/charge'         => 'charges#charge_card_saved'

    post '/charge'              => 'charges#charge_card_web'

    # namespace :api do
    #     match "/api/:controller(/:action(/*params))", via: [:get, :post]
    # end

    get '/auth/clover'     => 'clover/auth/auth_clover#authorize'

	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end
end
