PolicyManager::Engine.routes.draw do
  get 'documentation', to: 'application#doc', as: :documentation

  resources :user_portability_requests, only: %i[index create destroy]

  resources :portability_requests, only: %i[index destroy] do
    member do
      get :confirm
    end
  end

  resources :categories, only: %i[show index] do
    resources :terms, except: [:index]
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
