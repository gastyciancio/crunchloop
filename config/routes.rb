Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy]
    resources :todo_items, only: %i[index create update destroy]
  end

  resources :todo_lists, only: %i[index new create edit update destroy] do
    resources :todo_items, only: %i[index]
  end

  resources :todo_items, only: %i[new create edit update destroy]

  root to: redirect('/todo_lists')
end
