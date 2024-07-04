class CreateGuests < ActiveRecord::Migration[7.1]
  def change
    create_table :guests do |t|
      t.string :name
      t.integer :age
      t.string :city

      t.timestamps
    end
  end
end
