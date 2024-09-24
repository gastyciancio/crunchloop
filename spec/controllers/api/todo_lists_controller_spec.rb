require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

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

      it 'includes todo list records' do
        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(%w[id name])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when param is correct' do
      let(:valid_params) { { todo_list: { name: 'New Todo List' } } }

      it 'should create to do list successfully' do
        post :create, params: valid_params, format: :json

        to_do_list = JSON.parse(response.body)
        expect(to_do_list['name']).to eq('New Todo List')
        expect(response).to have_http_status(:created)
      end

      it 'should increment count of table ' do
        expect { post :create, params: valid_params, format: :json }.to change(TodoList, :count).by(1)
      end
    end
    context 'with invalid parameters' do
      let(:invalid_params) { { todo_list: { name: '' } } }

      it 'should not create to do list successfully' do
        post :create, params: invalid_params, format: :json
        create_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(create_response['errors']).to include("Name can't be blank")
        expect { post :create, params: invalid_params, format: :json }.not_to change(TodoList, :count)
      end
    end
  end

  describe 'PUT update' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install') }

    context 'when param is correct' do
      let(:valid_params) { { todo_list: { name: 'Updated Todo List' }, id: todo_list.id } }

      it 'should update to do list successfully' do
        put :update, params: valid_params, format: :json

        to_do_list = JSON.parse(response.body)
        expect(to_do_list['name']).to eq('Updated Todo List')
        todo_list.reload
        expect(todo_list.name).to eq('Updated Todo List')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { todo_list: { name: '' }, id: todo_list.id } }

      it 'should not update to do list successfully when name is blank' do
        put :update, params: invalid_params, format: :json
        update_response = JSON.parse(response.body)
        expect(update_response['errors']).to include("Name can't be blank")
        expect(response).to have_http_status(:unprocessable_entity)
        expect do
          put :update, params: invalid_params, format: :json
        end.not_to change(todo_list, :name)
      end

      it 'should not update todo list successfully when is not found' do
        put :update, params: { name: 'test', id: 99_999 }, format: :json
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Could not find item' })
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create(name: 'Run bundle install again') }

    context 'when id is correct' do
      it 'should destroy to do list successfully' do
        delete :destroy, params: { id: todo_list }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Todo list deleted' })
      end

      it 'should decrement count in table' do
        expect { delete :destroy, params: { id: todo_list }, format: :json }.to change(TodoList, :count).by(-1)
      end
    end

    context 'when id does not exist' do
      it 'should not delete todo list successfully' do
        delete :destroy, params: { id: 9999 }, format: :json

        expect(JSON.parse(response.body)).to eq({ 'error' => 'Could not find item' })
        expect { delete :destroy, params: { id: 9999 }, format: :json }.not_to change(TodoList, :count)
      end
    end
  end
end
