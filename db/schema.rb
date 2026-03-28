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

ActiveRecord::Schema[8.2].define(version: 2026_03_28_065556) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "flash_campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expired_at"
    t.string "influencer_name"
    t.integer "price"
    t.integer "remaining_stock", default: 0
    t.bigint "tenant_id", null: false
    t.string "title"
    t.integer "total_stock", default: 0
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_flash_campaigns_on_tenant_id"
    t.check_constraint "remaining_stock >= 0", name: "stock_cannot_be_negative"
  end

  create_table "flash_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "flash_campaign_id", null: false
    t.string "name"
    t.string "phone"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_flash_orders_on_email"
    t.index ["flash_campaign_id"], name: "index_flash_orders_on_flash_campaign_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "client_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "idempotency_key"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_orders_on_client_id"
    t.index ["coach_id"], name: "index_orders_on_coach_id"
    t.index ["idempotency_key"], name: "index_orders_on_idempotency_key", unique: true
    t.index ["tenant_id", "client_id", "status"], name: "idx_orders_on_tenant_client_status"
    t.index ["tenant_id"], name: "index_orders_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invitation_token"
    t.string "name"
    t.integer "orders_count"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["invitation_token"], name: "index_tenants_on_invitation_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.integer "role"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "flash_campaigns", "tenants"
  add_foreign_key "flash_orders", "flash_campaigns"
  add_foreign_key "orders", "tenants"
  add_foreign_key "orders", "users", column: "client_id"
  add_foreign_key "orders", "users", column: "coach_id"
  add_foreign_key "users", "tenants"
end
