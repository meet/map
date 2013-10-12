Map::Application.routes.draw do
  
  resources :users, :as => :directory_users do
    resource :mail, :password, :memberships, :mail_destination_inbox
  end
  resources :add_users do
    member do
      get 'resend_email'
    end
  end
  resources :groups, :as => :directory_groups
  
  resources :google_groups
  
  get 'logout' => 'application#logout'
  get 'search' => 'welcome#search'
  root :to => 'welcome#index'
  
end
