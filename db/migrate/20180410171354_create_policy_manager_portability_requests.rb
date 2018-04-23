class CreatePolicyManagerPortabilityRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :policy_manager_portability_requests do |t|
      #t.references :user, foreign_key: true
      t.integer :user_id, index: true
      t.string :state
      t.string :attachment
      t.string :attachment_file_name
      t.string :attachment_file_size
      t.datetime :attachment_content_type
      t.string :attachment_file_content_type

      t.datetime :expire_at

      t.timestamps
    end
  end
end
