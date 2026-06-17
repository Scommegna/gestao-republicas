class AddTipoToRepublicas < ActiveRecord::Migration[8.1]
  def change
    add_column :republicas, :tipo, :string, null: false, default: "mista"
  end
end
