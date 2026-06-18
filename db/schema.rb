# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_17_204731) do
  create_table "despesas", force: :cascade do |t|
    t.string "categoria", null: false
    t.datetime "created_at", null: false
    t.string "descricao", null: false
    t.integer "republica_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "vencimento", null: false
    t.index ["republica_id"], name: "index_despesas_on_republica_id"
  end

  create_table "pagamentos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data_pagamento", null: false
    t.integer "despesa_id", null: false
    t.integer "resident_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["despesa_id"], name: "index_pagamentos_on_despesa_id"
    t.index ["resident_id", "despesa_id"], name: "index_pagamentos_on_resident_id_and_despesa_id"
    t.index ["resident_id"], name: "index_pagamentos_on_resident_id"
    t.index ["status"], name: "index_pagamentos_on_status"
  end

  create_table "republicas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "endereco"
    t.string "name", null: false
    t.string "tipo", default: "mista", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_republicas_on_user_id"
  end

  create_table "residents", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.integer "republica_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["republica_id"], name: "index_residents_on_republica_id"
    t.index ["user_id", "republica_id"], name: "index_residents_on_user_id_and_republica_id", unique: true
    t.index ["user_id"], name: "index_residents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "jti", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["document"], name: "index_users_on_document", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "despesas", "republicas"
  add_foreign_key "pagamentos", "despesas"
  add_foreign_key "pagamentos", "residents"
  add_foreign_key "republicas", "users"
  add_foreign_key "residents", "republicas"
  add_foreign_key "residents", "users"
end
