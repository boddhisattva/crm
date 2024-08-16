# frozen_string_literal: true

class ValidateCreateDoorkeeperTables < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :oauth_access_tokens, :oauth_applications
  end
end
