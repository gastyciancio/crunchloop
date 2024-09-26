RSpec.describe TodoList, type: :model do
  it { should validate_presence_of(:name) }

  it { should have_many(:todo_items).dependent(:destroy) }

  describe 'validations' do
    it 'is valid with a name' do
      todo_list = TodoList.new(name: 'Daily tasks')

      expect(todo_list).to be_valid
    end

    it 'is not valid without a name' do
      todo_list = TodoList.new(name: nil)

      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:name]).to include("can't be blank")
    end
  end
end
