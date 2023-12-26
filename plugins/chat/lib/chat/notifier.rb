# frozen_string_literal: true

module Chat
  class Notifier
    class << self
      def user_has_seen_message?(membership, chat_message_id)
        (membership.last_read_message_id || 0) >= chat_message_id
      end

      def push_notification_tag(type, chat_channel_id)
        "#{Discourse.current_hostname}-chat-#{type}-#{chat_channel_id}"
      end
    end
  end
end
