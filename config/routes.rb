Pbook::Application.routes.draw do
    # get "portfolios/show"

    root                to: 'static_pages#home'
    match '/about',     to: 'static_pages#about'

    match '/signup',    to: 'users#new'
    match '/signin',    to: 'sessions#new'
    match '/signout',   to: 'sessions#destroy', via: :delete
    # match '/portfolio', to: 'portfolios#show'

    get "/profile", to: "users#profile"

    # http://localhost:3000/user/1/portfolio/0 (with actions 'show')
    get 'user/:id/portfolio/:id', to: 'users#show#portfolios#show'

    # ajax actions ---------------------------
    # users
    get "users/get_init_data"
    get "users/get_week_totals"
    get "users/select_portfolio"
    get "users/create_portfolio"
    get "users/remove_portfolio"

    get "users/select_week"
    get "users/create_week"
    get "users/remove_week"

    get "users/update_week_date"
    get "users/update_week_value"
    get "users/update_week_free_cash"
    get "users/update_week_comment"
    get "users/update_table_cell"
    get "users/add_table_row"
    get "users/remove_table_row"
    
    # traders
    get "traders/add_to_portfolio"
    get "traders/test_ajax"
    get "traders/test_get"
    post "traders/test_post"
    
    # portfolios
    get "portfolios/show_portfolio_data"
    get "portfolios/hide_portfolio_data"



    resources :sessions,        only: [:new, :create, :destroy]
    resources :users
    resources :portfolios,      only: [:index, :show]
    resources :traders,         only: [:index]




    # Viktor examples:
    # resources :work_list, :controller => 'work_list' do
    #     collection do
    #         get  :export
    #         post :import
    #         delete :reset
    #         get  :index
    #         post :create
    #         post :filtered
    #     end
    #     member do
    #         delete :destroy
    #     end
    # end

    # resources :feed_jobs do
    #     get  :owners,     :on => :collection
    #     get  :for_owner,  :on => :member
    #     get  :download,   :on => :member
    #     post :import,     :on => :member
    #     post :resync,     :on => :member
    #     post :resync_all, :on => :collection
    # end




    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    # Sample resource route with options:
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

    # Sample resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end

    # Sample resource route with more complex sub-resources
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', :on => :collection
    #     end
    #   end

    # Sample resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end

    # You can have the root of your site routed with "root"
    # just remember to delete public/index.html.
    # root :to => 'welcome#index'

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id))(.:format)'
end
