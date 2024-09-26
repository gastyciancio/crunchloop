require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install again') }
    let!(:todo_item) do
      TodoItem.create(title: 'Setup RoR project', description: 'Make sure you have everything you need',
                      todo_list_id: todo_list.id)
    end

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect do
          get :index
        end.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to be_an(Array)
      end

      it 'includes todo item records' do
        get :index, format: :json

        todo_items = JSON.parse(response.body)

        aggregate_failures 'includes the id title description and completed' do
          expect(todo_items.count).to eq(1)
          expect(todo_items[0].keys).to match_array(%w[id title description completed todo_list_id created_at
                                                       updated_at])
          expect(todo_items[0]['id']).to eq(todo_item.id)
          expect(todo_items[0]['title']).to eq(todo_item.title)
          expect(todo_items[0]['description']).to eq(todo_item.description)
          expect(todo_items[0]['completed']).to eq(todo_item.completed)
        end
      end
    end
  end

  describe 'POST create' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install again') }

    context 'when param is correct' do
      let(:valid_params) do
        { todo_item: { title: 'test', description: 'this is a description', todo_list_id: todo_list.id } }
      end

      it 'should create to do item successfully' do
        post :create, params: valid_params, format: :json

        to_do_item = JSON.parse(response.body)
        expect(to_do_item['title']).to eq('test')
        expect(to_do_item['description']).to eq('this is a description')
        expect(to_do_item['completed']).to eq(false)
      end

      it 'should increment count of table ' do
        expect { post :create, params: valid_params, format: :json }.to change(TodoItem, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { todo_item: { title: '', description: '', todo_list_id: todo_list.id } } }

      it 'should not create to do item successfully when title is not sended' do
        post :create, params: invalid_params, format: :json
        create_response = JSON.parse(response.body)
        expect(create_response['errors']).to include("Title can't be blank")
        expect(create_response['errors']).to include("Description can't be blank")
        expect { post :create, params: invalid_params, format: :json }.not_to change(TodoItem, :count)
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install again') }
    let!(:todo_item) do
      TodoItem.create(title: 'Setup RoR project', description: 'Make sure you have everything you need', completed: true,
                      todo_list_id: todo_list.id)
    end

    context 'when param is correct' do
      let(:valid_params) do
        { todo_item: { title: 'test', description: 'test description', completed: false }, id: todo_item }
      end

      it 'should update to do item successfully' do
        put :update, params: valid_params, format: :json

        to_do_item = JSON.parse(response.body)
        expect(to_do_item['title']).to eq('test')
        expect(to_do_item['description']).to eq('test description')
        expect(to_do_item['completed']).to eq(false)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { todo_item: { title: '', description: '' }, id: todo_list } }

      it 'should not update to do item successfully when title is blank' do
        put :update, params: invalid_params, format: :json
        update_response = JSON.parse(response.body)
        expect(update_response['errors']).to include("Title can't be blank")
        expect(update_response['errors']).to include("Description can't be blank")
        expect { put :update, params: invalid_params, format: :json }.not_to change(todo_item, :title)
      end

      it 'should not update todo item successfully when is not found' do
        put :update, params: { id: 9999, title: 'do not exist' }, format: :json
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Could not find item' })
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install again') }
    let!(:todo_item) do
      TodoItem.create(title: 'Setup RoR project', description: 'Make sure you have everything you need',
                      todo_list_id: todo_list.id)
    end

    context 'when id is correct' do
      it 'should destroy to do item successfully' do
        delete :destroy, params: { id: todo_item }, format: :json

        JSON.parse(response.body)
        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to eq({ 'message' => 'Todo item deleted' })
      end

      it 'should decrement count in table' do
        expect { delete :destroy, params: { id: todo_item }, format: :json }.to change(TodoItem, :count).by(-1)
      end
    end

    context 'when id does not exist' do
      it 'should not delete todo item successfully' do
        delete :destroy, params: { id: 9999 }, format: :json
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Could not find item' })
        expect { delete :destroy, params: { id: 9999 }, format: :json }.not_to change(TodoItem, :count)
      end
    end
  end
end
