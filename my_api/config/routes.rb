Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
  post "/articles", to: "articles#create"
  delete "/articles/:id", to: "articles#destroy"
end
