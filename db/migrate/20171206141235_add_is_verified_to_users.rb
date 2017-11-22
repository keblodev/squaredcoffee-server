class AddIsVerifiedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_verified, :boolean, default:false
  end
end
