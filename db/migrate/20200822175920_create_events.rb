class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description, null: false, default: ''
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.belongs_to :organization, null: false
      t.timestamps
    end
  end
end
