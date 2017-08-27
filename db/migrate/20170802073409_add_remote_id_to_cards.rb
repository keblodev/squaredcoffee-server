class AddRemoteIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :remote_id, :string
  end
end
