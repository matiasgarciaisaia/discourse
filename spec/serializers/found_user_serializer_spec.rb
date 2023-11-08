# frozen_string_literal: true

RSpec.describe FoundUserSerializer do
  fab!(:user)
  let(:serializer) { described_class.new(user, root: false) }

  describe "#id" do
    it "returns user id" do
      json = serializer.as_json
      expect(json.keys).to include :id
      expect(json[:id]).to eq(user.id)
    end
  end

  describe "#name" do
    it "returns name if enabled in site settings" do
      SiteSetting.enable_names = true
      json = serializer.as_json
      expect(json.keys).to include :name
      expect(json[:name]).to eq(user.name)
    end

    it "doesn't return name if disabled in site settings" do
      SiteSetting.enable_names = false
      json = serializer.as_json
      expect(json.keys).not_to include :name
    end
  end

  describe "#status" do
    fab!(:user_status) { Fabricate(:user_status) }

    before { user.user_status = user_status }

    it "adds user status when enabled" do
      SiteSetting.enable_user_status = true

      json = serializer.as_json

      expect(json[:status]).to_not be_nil do |status|
        expect(status.description).to eq(user_status.description)
        expect(status.emoji).to eq(user_status.emoji)
      end
    end

    it "doesn't add user status when disabled" do
      SiteSetting.enable_user_status = false
      json = serializer.as_json
      expect(json.keys).not_to include :status
    end

    it "doesn't add expired user status" do
      SiteSetting.enable_user_status = true

      user.user_status.ends_at = 1.minutes.ago
      serializer = described_class.new(user, scope: Guardian.new(user), root: false)
      json = serializer.as_json

      expect(json.keys).not_to include :status
    end

    it "doesn't return status if user doesn't have it" do
      SiteSetting.enable_user_status = true

      user.clear_status!
      user.reload
      json = serializer.as_json

      expect(json.keys).not_to include :status
    end
  end
end
