# frozen_string_literal: true

class CreatePagamentos < ActiveRecord::Migration[8.1]
  def change
    create_table :pagamentos do |t|
      t.references :resident, null: false, foreign_key: true
      t.references :despesa, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data_pagamento, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :pagamentos, :status
    add_index :pagamentos, [ :resident_id, :despesa_id ]
  end
end
