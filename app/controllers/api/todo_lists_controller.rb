module Api
  class TodoListsController < ApplicationController
    before_action :find_item, only: %i[update destroy]

    def index
      @todo_lists = TodoList.all

      respond_to :json
    end

    def create
      @to_item = TodoList.new(todo_list_params)

      if @to_item.save
        render json: @to_item, status: :created
      else
        render json: { errors: @to_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @to_item.update(todo_list_params)
        render json: @to_item
      else
        render json: { errors: @to_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @to_item.destroy
      render json: { message: 'Todo list deleted' }, status: :ok
    end

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

    def find_item
      @to_item = TodoList.find(params[:id])
    end
  end
end
