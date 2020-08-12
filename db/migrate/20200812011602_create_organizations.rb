class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.integer :total_members, null: false, default: 0
      t.text :description, null: false, default: ''
      t.timestamps
    end

    add_index :organizations, :name, unique: true
  end
end
