Map::Application.routes.draw do
  
  resources :users, :as => :directory_users do
    resource :mail, :password, :memberships
  end
  resources :add_users
  resources :groups, :as => :directory_groups
  
  resources :google_groups
  
  get 'logout' => 'application#logout'
  get 'search' => 'welcome#search'
  root :to => 'welcome#index'
  
end
