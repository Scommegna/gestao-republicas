class CreateRepublicas < ActiveRecord::Migration[8.1]
  def change
    create_table :republicas do |t|
      t.string :name, null: false
      t.string :endereco
      t.text :descricao
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
