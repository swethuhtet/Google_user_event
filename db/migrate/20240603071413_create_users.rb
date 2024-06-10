class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :encrypted_password
      t.text :about_me
      t.text :profile

      t.timestamps
    end
  end
end
