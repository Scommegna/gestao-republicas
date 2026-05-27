# frozen_string_literal: true

class CreateDespesas < ActiveRecord::Migration[8.1]
  def change
    create_table :despesas do |t|
      t.references :republica, null: false, foreign_key: true
      t.string :descricao, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :vencimento, null: false
      t.string :categoria, null: false

      t.timestamps
    end
  end
end
