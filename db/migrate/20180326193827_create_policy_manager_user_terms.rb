class CreatePolicyManagerUserTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :policy_manager_user_terms do |t|
      t.integer :user_id, index: true
      t.integer :term_id, index: true
      t.string :state, index: true

      t.timestamps
    end
    #add_index :terms_user_terms, :state
  end
end
