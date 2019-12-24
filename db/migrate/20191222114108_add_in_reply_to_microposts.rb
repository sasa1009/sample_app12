class AddInReplyToMicroposts < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :in_reply_to, :integer, default:0
    add_index :microposts, :in_reply_to
  end
end
