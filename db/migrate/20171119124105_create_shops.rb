class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :remote_id
      t.string :vendor_id
      t.string :name
      t.text :desc
      t.string :token

      t.timestamps null: false
    end
  end
end
