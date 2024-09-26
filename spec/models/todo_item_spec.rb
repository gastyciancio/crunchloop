RSpec.describe TodoItem, type: :model do

  it { should belong_to(:todo_list) }
 
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      todo_list = TodoList.create(name: 'Daily tasks')
      todo_item = TodoItem.new(title: 'Setup RoR project', description: 'Install gems', todo_list: todo_list)

      expect(todo_item).to be_valid
    end

    it 'is not valid without a title' do
      todo_item = TodoItem.new(title: nil)

      expect(todo_item).not_to be_valid
      expect(todo_item.errors[:title]).to include("can't be blank")
    end

    it 'is not valid without a description' do
      todo_item = TodoItem.new(description: nil)

      expect(todo_item).not_to be_valid
      expect(todo_item.errors[:description]).to include("can't be blank")
    end
  end
end