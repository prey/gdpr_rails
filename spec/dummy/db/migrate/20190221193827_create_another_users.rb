class CreateAnotherUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :another_users do |t|
      t.string :email

      t.timestamps
    end
  end
end
