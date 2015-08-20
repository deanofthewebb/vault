Vault::Application.routes.draw do
  get 'cb_employees/home'

  get 'secret_files/home'

  get 'secret_files/help'

  get 'secret_files/about'

#Rails.application.routes.draw do
  get 'cb_employees/home'

  get 'secret_files/home'

  get 'secret_files/help'

  get 'secret_files/about'

  resources :cb_employees do
    get :autocomplete_cb_employees_network_name, :on => :collection
    get :filter_viewers, :on => :collection
  end

  # resources :cb_employees do
  #   get 'filter_viewers', :on => :member
  # end

  devise_for :users
  resources :secret_files 
  get ':controller(/:action(/:id))'
  post ':controller(/:action(/:id))'
  delete ':controller(/:action(/:id))'
  patch ':controller(/:action(/:id))'

 

  root to: 'cb_employees#home'

  match '/help',    to: 'secret_files#help',    via: 'get'
  match '/about',   to: 'secret_files#about',   via: 'get'
  match '/home', to: 'cb_employees#home', via: 'get'
  match '/index', to: 'secret_files#index', via: 'get'
  match '/view' => 'secret_files#view', via: 'get'
  #match '/sign_out' => 'devise/sessions#destroy', via: 'get'
  match '/sign_out' => 'saml#logout', via: 'get'

  match '/edit_access' => 'cb_employees#edit_access', via: 'post'
  match '/reset_access' => 'cb_employees#reset_access', via: 'post'
  match '/cb_employees/filter_viewers' => 'cb_employees#filter_viewers', via: 'get'

  post "/set_delete_var_true", :to=>"secret_files#set_params_delete_var_true"

  post "/set_delete_var_false", :to=>"secret_files#set_params_delete_var_false"

  post "/delete_files", :to=>"secret_files#delete_files"


  match "/saml/consume", :to=>"saml#consume", :via => [:get, :post]

  match "/saml/logout", :to=>"saml#logout", :via => [:get, :post]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
