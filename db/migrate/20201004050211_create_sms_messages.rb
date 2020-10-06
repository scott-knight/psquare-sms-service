class CreateSmsMessages < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    create_table :sms_messages, id: :uuid do |t|
      t.string   :phone_number, null: false, limit: 15
      t.text     :message_txt, null: false
      t.string   :message_uuid, limit: 80
      t.string   :status
      t.integer  :status_code
      t.integer  :total_tries
      t.string   :url_domain
      t.string   :url_path
      t.tsvector :tsv
      t.datetime :discarded_at

      t.timestamps null: false
    end

    # trigger updates on indexing for tsvector searches
    execute <<-SQL.squish
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON sms_messages FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(tsv, 'pg_catalog.english', message_txt);
    SQL

    # allows for vector searches, makes it super fast
    add_index(:sms_messages, :tsv, using: 'gin')

    # speeds up %string% searches significantly
    add_index(:sms_messages, :phone_number, using: :gin, opclass: {phone_number: :gin_trgm_ops}, algorithm: :concurrently)
    add_index(:sms_messages, :message_uuid, using: :gin, opclass: {message_uuid: :gin_trgm_ops}, algorithm: :concurrently)
    add_index(:sms_messages, :status, using: :gin, opclass: {status: :gin_trgm_ops}, algorithm: :concurrently)
    add_index(:sms_messages, :url_domain, using: :gin, opclass: {url_domain: :gin_trgm_ops}, algorithm: :concurrently)
    add_index(:sms_messages, :url_path, using: :gin, opclass: {url_path: :gin_trgm_ops}, algorithm: :concurrently)
    add_index(:sms_messages, :total_tries)
    add_index(:sms_messages, :status_code)
  end

  def down
    remove_index(:sms_messages, :status_code)
    remove_index(:sms_messages, :total_tries)
    remove_index(:sms_messages, :url)
    remove_index(:sms_messages, :status)
    remove_index(:sms_messages, :message_uuid)
    remove_index(:sms_messages, :phone_number)
    remove_index(:sms_messages, :tsv)

    execute <<-SQL.squish
      DROP TRIGGER tsvectorupdate
      ON sms_messages
    SQL

    drop_table(:sms_messages)
  end
end
