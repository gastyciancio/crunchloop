class TodoItemsController < ApplicationController
  before_action :find_item, only: %i[update edit destroy show]
  before_action :find_todo_list, only: %i[index create]
  def index
    @todo_items = @todo_list.todo_items

    respond_to :html
  end

  def new
    @todo_item = TodoItem.new

    respond_to :html
  end

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    if @todo_item.save
      handle_successful_create
    else
      handle_failed_create
    end
  end

  def edit
    @todo_list = @todo_item.todo_list
  end

  def update
    if @todo_item.update(todo_item_params)
      redirect_to todo_list_todo_items_path(todo_list_id: @todo_item.todo_list_id)
    else
      handle_failed_update
    end
  end

  def destroy
    @todo_item.destroy
    render turbo_stream: [turbo_stream.remove(@todo_item)]
  end

  private

  def todo_item_params
    params.require(:todo_item).permit(:title, :description, :completed, :todo_list_id)
  end

  def find_item
    @todo_item = TodoItem.find(params[:id])
  end

  def find_todo_list
    @todo_list = TodoList.find(params[:todo_list_id] || todo_item_params[:todo_list_id])
  end

  def handle_successful_create
    render turbo_stream: [
      turbo_stream.update('new_todoitem', partial: 'todo_items/new',
                                          locals: { todo_item: TodoItem.new,
                                                    todo_list: @todo_item.todo_list }),
      turbo_stream.append('added_new_todoitem', partial: 'todo_items/todoitem',
                                                locals: { todo_item: TodoItem.find(@todo_item.id) })
    ]
  end

  def handle_failed_create
    render turbo_stream: [turbo_stream.update('create_todoitem_error'.to_sym, partial: '/feedback',
                                                                              locals: { messages: @todo_item.errors.messages })],
           status: :unprocessable_entity
  end

  def handle_failed_update
    render turbo_stream: [turbo_stream.update('update_todoitem_error'.to_sym, partial: '/feedback',
                                                                              locals: { messages: @todo_item.errors.messages })],
           status: :unprocessable_entity
  end
end
