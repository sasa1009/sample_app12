class AddFollowNotificationToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :follow_notification, :boolean, default:false
  end
  def down
    remove_column :users, :follow_notification, :boolean, default:false
  end
end
