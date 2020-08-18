class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :user, null: false, index: { unique: true }
      t.belongs_to :organization, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
