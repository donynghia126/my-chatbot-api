class AddPinnedToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :pinned, :boolean, default: false, null: false
  end
end
