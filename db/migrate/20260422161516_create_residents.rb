class CreateResidents < ActiveRecord::Migration[8.1]
  def change
    create_table :residents do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :republica, null: false, foreign_key: true

      t.timestamps
    end
  end
end
