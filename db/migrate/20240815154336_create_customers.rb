# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false, comment: 'User first name'
      t.string :surname, null: false, comment: 'User last name'
      t.references :created_by, null: false, foreign_key: { to_table: :users },
                                comment: 'This references the user which created the customer'
      t.references :last_modified_by, null: false, foreign_key: { to_table: :users },
                                      comment: 'This references the user who last modified the customer\'s data'

      t.timestamps
    end
  end
end
