Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :disburser_requests, only: :index, path: 'requests'
  resources :repositories do
    resources :repository_users
    resources :disburser_requests, except: :index, path: 'requests' do
      member do
        get :download_file
      end
    end
    resources :specimen_types, only: :index do
      collection do
        patch 'bulk_update'
      end
    end
    member do
      get :download_file
    end

    resource :content, only: [:edit, :update]
  end

  resources :users, only: [:index, :show]

  root 'home#index'
end
