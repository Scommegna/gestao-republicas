class AddPhoneToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone, :string, null: false
    add_index :users, :phone, unique: true
  end
end
