# frozen_string_literal: true

class Customer < ApplicationRecord
  has_one_attached :photo

  acts_as_paranoid

  # TODO: Add model test
  def photo_url
    Rails.application.routes.url_helpers.url_for(photo) if photo.attached?
  end

  belongs_to :created_by, class_name: 'User'
  belongs_to :last_modified_by, class_name: 'User'

  validates :name, :surname, :created_by, :last_modified_by, :identifier, presence: true

  # TODO: think about if we would still like to have this given we now have an additional unique identifier field
  validates :name, uniqueness: { scope: %i[surname created_by] }
end
