class AddOrdersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :orders, :string, array: true, default:[]
  end
end
