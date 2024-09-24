Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy], path: :todolists
    resources :todo_items, only: %i[index create update destroy], path: :todoitems

  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
