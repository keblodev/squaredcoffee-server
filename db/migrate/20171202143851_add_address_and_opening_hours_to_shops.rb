class AddAddressAndOpeningHoursToShops < ActiveRecord::Migration
  def change
    add_column :shops, :address, :string
    add_column :shops, :opening_hours, :string
  end
end
