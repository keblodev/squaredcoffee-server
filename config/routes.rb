Rails.application.routes.draw do

    # SQUAREUP

	get 'root/index'
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

    # CLOVER

    get '/auth/clover'          => 'clover/auth/auth_clover#authorize'
    get '/shops/clover'         => 'clover/merchant/merchants_clover#getAll'
    get '/shops/clover/refetch' => 'clover/merchant/merchants_clover#refetchAll'

    get '/shops/clover/:id'                 => 'clover/merchant/merchants_clover#get'

    get '/shops/clover/:id/categories'      => 'clover/merchant/items_clover#get_all_categories_with_items'
    get '/shops/clover/:id/items'           => 'clover/merchant/items_clover#get_all_with_modifies'
    get '/shops/clover/:id/items/:itemId'   => 'clover/merchant/items_clover#get_with_modifiers'

    post '/shops/clover/:id/order/new'                   => 'clover/merchant/order_clover#new'
    get '/shops/clover/:id/order/:order_id'              => 'clover/merchant/order_clover#get'
    get '/shops/clover/order/:order_id/receipt'          => 'clover/merchant/order_clover#get_receipt'
    post '/shops/clover/:id/order/:order_id/update'      => 'clover/merchant/order_clover#update'
    post '/shops/clover/:id/order/:order_id/delete'      => 'clover/merchant/order_clover#delete'

    post '/shops/clover/:merchant_id/order/:order_id/pay' => 'clover/merchant/pay_clover#pay'
    post '/shops/clover/:merchant_id/order/:order_id/cancel' => 'clover/merchant/order_clover#cancel'
    post '/shops/clover/:merchant_id/order/:order_id/remove' => 'clover/merchant/order_clover#remove'

    get '/shops/clover/config/remote'   => 'clover/assets/images_clover#get_configs'
    get '/shops/clover/images/:fileId'  => 'clover/assets/images_clover#get'

    post '/user/shop/clover/orders' => 'clover/merchant/order_clover#get_user_orders'

    post '/user/update/me'              => 'users#update_me'
    post '/user/password/reset'         => 'users#password_reset'
    post '/user/password/forgot'        => 'users#password_forgot'
    get '/user/password/reset'          => 'auth#password_reset'
    post '/user/password/reset_action'  => 'auth#password_reset_action'
    post '/user/email/validate/resend'  => 'users#validate_email_resend'
    get '/auth/email/validate'          => 'auth#validate_email'
    get '/auth/email/invalidate'        => 'auth#invalidate_email'

    get '/user/passwprd/reset_tst' => 'auth#password_reset_tst'
end
