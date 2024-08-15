class Customer < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :last_modified_by, class_name: 'User'

  validates_presence_of :name, :surname, :created_by, :last_modified_by

  validates_uniqueness_of :name, scope: :surname
end
