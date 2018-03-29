PolicyManager::Engine.routes.draw do

  resources :categories do 
    resources :terms
  end
  resources :terms_categories
  resources :user_terms do 
    collection do 
      get :pending
    end
    
    member do
      put :accept 
      put :reject 
    end
  end
  #resources :terms
  root 'dashboard#index'

end
