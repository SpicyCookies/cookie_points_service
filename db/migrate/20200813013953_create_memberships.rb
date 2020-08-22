class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :user, null: false
      t.belongs_to :organization, null: false
      t.timestamps
    end

    add_index :memberships, [:user_id, :organization_id], unique: true
  end
end
