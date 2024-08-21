# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:surname) }
  it { is_expected.to validate_presence_of(:created_by) }
  it { is_expected.to validate_presence_of(:last_modified_by) }
  it { is_expected.to validate_presence_of(:identifier) }
end
