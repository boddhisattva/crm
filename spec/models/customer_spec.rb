# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }
  it { is_expected.to validate_presence_of(:created_by) }
  it { is_expected.to validate_presence_of(:last_modified_by) }
  it { is_expected.to validate_presence_of(:identifier) }

  it { is_expected.to validate_content_type_of(:photo).allowing('image/png', 'image/jpg', 'image/jpeg') }
  it { is_expected.to validate_dimensions_of(:photo).width_max(4000).with_message('is not given between dimension') }
  it { is_expected.to validate_dimensions_of(:photo).height_max(6000).with_message('is not given between dimension') }
  it { is_expected.to validate_size_of(:photo).less_than(2.megabytes).with_message('is too large') }
  # TODO: Update matcher once the gem version is updated. More details: https://github.com/igorkasyanchuk/active_storage_validations/issues/246#issuecomment-2208579434
  it { is_expected.to ActiveStorageValidations::Matchers::AspectRatioValidatorMatcher.new(:photo).allowing(:portrait) }

  describe '#photo_url' do
    context 'when a customer has a photo' do
      let(:customer) { create(:customer) }

      before { customer }

      it 'generates a photo url' do
        expect(customer.photo_url).to include('faith_can_move_mountains_rachel_unsplash.jpg')
      end
    end

    context 'when a customer does not have a photo' do
      let(:customer) { create(:customer, photo: nil) }

      before { customer }

      it 'returns nil' do
        expect(customer.photo_url).to be_nil
      end
    end
  end
end
