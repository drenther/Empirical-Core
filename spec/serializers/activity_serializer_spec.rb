require 'rails_helper'

describe ActivitySerializer, type: :serializer do
  it_behaves_like 'serializer' do
    let(:record_instance) { FactoryGirl.create(:activity) }

    let(:expected_serialized_keys) do
      %w(anonymous_path
         classification
         created_at
         data
         description
         flags
         id
         name
         topic
         uid
         updated_at
         activity_category
         )
    end
  end
end
