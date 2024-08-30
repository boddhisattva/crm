# frozen_string_literal: true

class AddUniqueIdentifierConstraintToCustomers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :customers, :identifier, unique: true, algorithm: :concurrently
  end
end
