# frozen_string_literal: true

RSpec.describe "List channels | sidebar", type: :system, js: true do
  fab!(:current_user) { Fabricate(:user) }

  let(:chat) { PageObjects::Pages::Chat.new }

  before do
    chat_system_bootstrap
    SiteSetting.navigation_menu = "sidebar"
    sign_in(current_user)
  end

  context "when channels present" do
    context "when category channel" do
      fab!(:category_channel_1) { Fabricate(:category_channel) }

      context "when member of the channel" do
        before do
          category_channel_1.add(current_user)
          visit("/")
        end

        it "shows the channel in the correct section" do
          expect(page.find(".sidebar-section-chat-channels")).to have_content(
            category_channel_1.name,
          )
        end

        it "doesn’t show the core channels list" do
          expect(page).to have_no_selector(".channels-list")
        end
      end

      context "when not member of the channel" do
        before { visit("/") }

        it "doesn’t show the channel" do
          expect(page).to have_no_content(category_channel_1.name)
        end
      end
    end

    context "when direct message channels" do
      fab!(:dm_channel_1) { Fabricate(:direct_message_channel, users: [current_user]) }
      fab!(:inaccessible_dm_channel_1) { Fabricate(:direct_message_channel) }

      context "when member of the channel" do
        before { visit("/") }

        it "shows the channel in the correct section" do
          expect(page.find(".sidebar-section-chat-dms")).to have_content(current_user.username)
        end
      end

      context "when not member of the channel" do
        before { visit("/") }

        it "doesn’t show the channel" do
          expect(page).to have_no_content(inaccessible_dm_channel_1.title(current_user))
        end
      end
    end
  end

  context "when no category channels" do
    it "doesn’t show the section" do
      visit("/")
      expect(page).to have_no_css(".sidebar-section-chat-channels")
    end

    context "when user can create channels" do
      before { current_user.update!(admin: true) }

      it "shows the section" do
        visit("/")
        expect(page).to have_css(".sidebar-section-chat-channels")
      end
    end
  end

  context "when no direct message channels" do
    before { visit("/") }

    it "shows the section" do
      expect(page).to have_css(".sidebar-section-chat-dms")
    end
  end

  context "when user can’t chat" do
    before do
      SiteSetting.chat_enabled = false
      visit("/")
    end

    it "doesn’t show the sections" do
      expect(page).to have_no_css(".sidebar-section-chat-channels")
      expect(page).to have_no_css(".sidebar-section-chat-dms")
    end
  end

  context "when user has chat disabled" do
    before do
      SiteSetting.chat_enabled = false
      current_user.user_option.update!(chat_enabled: false)
      visit("/")
    end

    it "doesn’t show the sections" do
      expect(page).to have_no_css(".sidebar-section-chat-channels")
      expect(page).to have_no_css(".sidebar-section-chat-dms")
    end
  end

  context "when leaving a channel" do
    context "when dm channel" do
      fab!(:dm_channel_1) { Fabricate(:direct_message_channel, users: [current_user]) }

      it "removes it from the sidebar" do
        visit("/")

        find(".sidebar-row.channel-#{dm_channel_1.id}").hover
        find(".sidebar-row.channel-#{dm_channel_1.id} .sidebar-section-hover-button").click

        expect(page).to have_no_selector(".sidebar-row.channel-#{dm_channel_1.id}")
      end
    end
  end
end
