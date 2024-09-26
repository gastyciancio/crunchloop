module Api
  class TodoItemsController < ApplicationController
    before_action :find_item, only: %i[update destroy]

    def index
      @todo_items = TodoItem.all

      respond_to do |format|
        format.json { render json: @todo_items }
      end
    end

    def create
      @todo_item = TodoItem.new(todo_item_params)

      if @todo_item.save
        render json: @todo_item, status: :created
      else
        render_errors
      end
    end

    def update
      if @todo_item.update(todo_item_params)
        render json: @todo_item, status: :ok
      else
        render_errors
      end
    end

    def destroy
      @todo_item.destroy
      render json: { message: 'Todo item deleted' }, status: :ok
    end

    private

    def todo_item_params
      params.require(:todo_item).permit(:title, :description, :completed, :todo_list_id)
    end

    def find_item
      @todo_item = TodoItem.find(params[:id])
    end

    def render_errors
      render json: { errors: @todo_item.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
