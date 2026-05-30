# frozen_string_literal: true

class AddActiveToResidents < ActiveRecord::Migration[8.1]
  def change
    add_column :residents, :active, :boolean, default: true, null: false
  end
end
