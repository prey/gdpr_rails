PolicyManager::Engine.routes.draw do

  resources :user_portability_requests, only: [:index, :create, :destroy]

  resources :portability_requests, only: [:index, :destroy] do
    member do
      get :confirm
    end
  end
  
  resources :categories, only: [:show, :index] do 
    resources :terms
  end

  resources :user_terms, only: [:show] do 
    collection do 
      get :pending
      put :accept_multiples
      get :blocking_terms
    end
    
    member do
      put :accept 
      put :reject 
    end
  end
  
  root 'categories#index'
end
