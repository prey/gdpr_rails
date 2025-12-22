class CreatePolicyManagerPortabilityRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :policy_manager_portability_requests do |t|
      # t.references :user, foreign_key: true
      t.integer :user_id, index: true
      t.string :state
      t.datetime :expire_at
      t.timestamps
    end
  end
end
