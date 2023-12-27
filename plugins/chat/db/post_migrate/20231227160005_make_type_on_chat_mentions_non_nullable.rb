# frozen_string_literal: true

class MakeTypeOnChatMentionsNonNullable < ActiveRecord::Migration[7.0]
  def change
    change_column :chat_mentions, :type, :string, null: false
  end
end
