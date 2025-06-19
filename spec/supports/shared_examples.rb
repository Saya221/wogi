# frozen_string_literal: true

shared_examples :concerns do
  it { expect(described_class).to be_paranoid }
  it { expect(PaperTrail.request.enabled_for_model?(described_class)).to be true }
end

shared_examples :filter_and_sort do
  let(:underscore_class_name) { described_class.name.underscore }

  let!("#{described_class.name.underscore}1") { create(underscore_class_name, id: MethodsHelper::UUID11) }
  let!("#{described_class.name.underscore}2") { create(underscore_class_name, id: MethodsHelper::UUID578) }

  let(:subject1) { send("#{underscore_class_name}1") }
  let(:subject2) { send("#{underscore_class_name}2") }

  describe ".filter_by" do
    context "id" do
      let(:conditions) { { id: MethodsHelper::UUID11 } }

      it { expect(described_class.filter_by(conditions)).to eq [subject1] }
    end

    context "default" do
      let(:conditions) {}

      it { expect(described_class.filter_by(conditions)).to eq [subject1, subject2] }
    end
  end

  describe ".conditions_sort" do
    context "id" do
      let(:conditions) { { id: :asc } }

      it { expect(described_class.conditions_sort(conditions)).to eq [subject1, subject2] }
    end

    context "default" do
      context "conditions is Hash" do
        let(:conditions) { {} }

        it { expect(described_class.conditions_sort(conditions)).to eq [subject2, subject1] }
      end

      context "conditions is nil" do
        let(:conditions) {}

        it { expect(described_class.conditions_sort(conditions)).to eq [subject2, subject1] }
      end
    end
  end
end

shared_examples :not_found do |resource|
  it do
    expect(response).to have_http_status(:not_found)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq nil
    expect(response_data[:errors][0][:code]).to eq 1051
  end
end

shared_examples :blank do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1003
  end
end

shared_examples :taken do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1008
  end
end

shared_examples :invalid do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1009
  end
end

shared_examples :not_a_number do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1013
  end
end

shared_examples :greater_than do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1014
  end
end

shared_examples :less_than do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1017
  end
end

shared_examples :wrong_format do |resource, field|
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:resource]).to eq resource
    expect(response_data[:errors][0][:field]).to eq field
    expect(response_data[:errors][0][:code]).to eq 1800
  end
end

shared_examples :unauthorized do |action|
  before { action }

  it do
    expect(response).to have_http_status(:unauthorized)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:code]).to eq 1201
  end
end

shared_examples :forbidden do |action|
  before { action }

  it do
    expect(response).to have_http_status(:forbidden)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:code]).to eq 1202
  end
end

shared_examples :invalid_card_state do |action|
  before { action }

  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:code]).to eq 1900
  end
end

shared_examples :parameter_missing do
  it do
    expect(response).to have_http_status(:bad_request)
    expect(response_data[:success]).to eq false
    expect(response_data[:errors][0][:code]).to eq 1200
  end
end
