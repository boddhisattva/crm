# frozen_string_literal: true

class AddIdentifierToCustomers < ActiveRecord::Migration[7.1]
  def change
    # rubocop:disable Rails/NotNullColumn
    add_column :customers, :identifier, :uuid, null: false
    # rubocop:enable Rails/NotNullColumn
  end
end
