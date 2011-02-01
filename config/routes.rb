Map::Application.routes.draw do
  
  resources :users, :as => :directory_users do
    resource :mail, :password, :memberships
  end
  resources :groups, :as => :directory_groups
  
  match 'search' => 'welcome#search'
  root :to => 'welcome#index'
  
end
