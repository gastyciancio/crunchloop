class TodoListsController < ApplicationController
  before_action :find_list, only: %i[update edit destroy show]
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      handle_successful_create
    else
      handle_failed_create
    end
  end

  def edit; end

  def update
    if @todo_list.update(todo_list_params)
      redirect_to todo_lists_path
    else
      handle_failed_update
    end
  end

  def destroy
    @todo_list.destroy
    render turbo_stream: [turbo_stream.remove(@todo_list)]
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def find_list
    @todo_list = TodoList.find(params[:id])
  end

  def handle_successful_create
    render turbo_stream: [
      turbo_stream.update('new_todolist', partial: 'todo_lists/new', locals: { todo_list: TodoList.new }),
      turbo_stream.append('added_new_todolist', partial: 'todo_lists/todolist', locals: { todo_list: @todo_list })
    ]
  end

  def handle_failed_create
    render turbo_stream: [
      turbo_stream.update('create_todolist_error'.to_sym, partial: '/feedback', locals: { messages: @todo_list.errors.messages })
    ], status: :unprocessable_entity
  end

  def handle_failed_update
    render turbo_stream: [
      turbo_stream.update('update_todolist_error'.to_sym, partial: '/feedback', locals: { messages: @todo_list.errors.messages })
    ], status: :unprocessable_entity
  end
end
