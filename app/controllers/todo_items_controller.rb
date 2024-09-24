class TodoItemsController < ApplicationController
  # GET /todoitems
  def index
    @todo_items = TodoItem.all

    respond_to :html
  end

  # GET /todoitems/new
  def new
    @todo_item = TodoItem.new

    respond_to :html
  end
end
