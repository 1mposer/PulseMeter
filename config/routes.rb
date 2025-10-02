Rails.application.routes.draw do
  # HTML routes for dashboard
  get "/dashboard", to: "dashboard#index"
  get "/ui/:panel", to: "ui#show", as: :ui_panel

  # HTML routes for drawer content
  resources :tables, only: [:show]
  resources :consoles, only: [:show]

  # HTML routes for reservations
  resources :reservations, only: [:show, :new] do
    collection do
      get :available
      get :active
    end
    member do
      post :check_in
      post :end
      post :extend
      post :cancel
      post :no_show
    end
  end

  # API routes (JSON-only)
  scope defaults: { format: :json } do
    resource :scan, only: [] do
      post ":tag_token/open", to: "scans#open", as: :open
    end

    resources :sessions, only: [:create, :update, :show] do
      member do
        patch :assign_member
        post :void
        post :drink_purchases, to: "sessions#create_drink_purchase"
        post :food_purchases, to: "sessions#create_food_purchase"
      end
    end

    resources :receipt_ocr, only: [:create, :show, :index] do
      collection do
        get :export_csv
      end
    end
  end
end
