# db/migrate/xxxxxxxx_add_admin_to_users.rb
class AddAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    # Thêm cột 'admin' kiểu boolean, không cho phép null, và mặc định là false
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
