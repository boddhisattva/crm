# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.authenticate' do
    context "when user user logins via '/oauth/token' flow(provided out of box by Doorkeeper gem)" do
      context 'when credentials are valid' do
        let(:user) { create(:user) }

        it 'returns the user' do
          expect(described_class.authenticate(user.email, user.password)).to eq(user)
        end
      end

      context 'when credentials are invalid' do
        it 'returns nil' do
          expect(described_class.authenticate('invalid email', 'user_password')).to be_nil
        end
      end
    end
  end
end
