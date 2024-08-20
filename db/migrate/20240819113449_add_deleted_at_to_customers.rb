# frozen_string_literal: true

class AddDeletedAtToCustomers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :customers, :deleted_at, :datetime

    add_index :customers, :deleted_at, algorithm: :concurrently
  end
end
