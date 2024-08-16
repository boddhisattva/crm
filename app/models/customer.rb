# frozen_string_literal: true

class Customer < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :last_modified_by, class_name: 'User'

  validates :name, :surname, :created_by, :last_modified_by, presence: true

  validates :name, uniqueness: { scope: :surname }
end
