class AddUserToResidents < ActiveRecord::Migration[8.1]
  def change
    add_reference :residents, :user, null: true, foreign_key: true

    # Um usuário só pode participar de uma república uma vez.
    # (NULLs são distintos no SQLite, então moradores sem usuário não conflitam.)
    add_index :residents, [ :user_id, :republica_id ], unique: true
  end
end
