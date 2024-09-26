class CreateTodoItem < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.boolean :completed, default: false
      t.references :todo_list, foreign_key: true

      t.timestamps
    end
  end
end
