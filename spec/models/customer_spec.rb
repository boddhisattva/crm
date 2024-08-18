# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }
  it { is_expected.to validate_presence_of(:created_by) }
  it { is_expected.to validate_presence_of(:last_modified_by) }

  context 'when name & surname are same for more than one customers' do
    let(:customer) { create(:customer, name: 'Raj', surname: 'Singh') }

    context 'when user who created these customers are the same' do
      let(:other_customer) { build(:customer, name: 'Raj', surname: 'Singh', created_by: customer.created_by) }

      it 'treats the other customer record as invalid' do
        expect(other_customer).not_to be_valid
      end
    end

    context 'when user who created these customers are different' do
      let(:other_customer) { build(:customer, name: 'Raj', surname: 'Singh') }

      it 'treats the other customer record as valid' do
        expect(other_customer).to be_valid
      end
    end
  end

end
