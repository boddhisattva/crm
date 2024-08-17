# frozen_string_literal: true

class AddRoleToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 0, comment: 'Useful to have different role types like admin etc.,'
  end
end
