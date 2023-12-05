# frozen_string_literal: true

class AddIndexToTargetIdOnChatMentions < ActiveRecord::Migration[7.0]
  def change
    add_index :chat_mentions, %i[target_id]
  end
end
