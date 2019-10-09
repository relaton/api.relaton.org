Rails.application.routes.draw do
  root "homes#show"

  namespace :api do
    resource :standard, only: [:show]
  end
end
