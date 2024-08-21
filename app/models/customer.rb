# frozen_string_literal: true

class Customer < ApplicationRecord
  acts_as_paranoid

  has_one_attached :photo
  belongs_to :created_by, class_name: 'User'
  belongs_to :last_modified_by, class_name: 'User'

  validates :name, :surname, :created_by, :last_modified_by, :identifier, presence: true

  validates :photo, content_type: ['image/png', 'image/jpeg', 'image/jpg'],
                    size: { less_than: 2.megabytes, message: 'is too large' },
                    aspect_ratio: :portrait,
                    dimension: { width: { max: 4000 },
                                 height: { max: 6000 }, message: 'is not given between dimension' }

  def photo_url
    Rails.application.routes.url_helpers.url_for(photo) if photo.attached?
  end
end
