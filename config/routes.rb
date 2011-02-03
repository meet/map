Map::Application.routes.draw do
  
  resources :users, :as => :directory_users do
    resource :mail, :password, :memberships
  end
  resources :groups, :as => :directory_groups
  
  get 'logout' => 'application#logout'
  get 'search' => 'welcome#search'
  root :to => 'welcome#index'
  
end
