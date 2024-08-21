# frozen_string_literal: true

class Customer < ApplicationRecord
  acts_as_paranoid

  has_one_attached :photo
  belongs_to :created_by, class_name: 'User'
  belongs_to :last_modified_by, class_name: 'User'

  validates :name, :surname, :created_by, :last_modified_by, :identifier, presence: true

  # TODO: Add model test
  def photo_url
    Rails.application.routes.url_helpers.url_for(photo) if photo.attached?
  end
end
