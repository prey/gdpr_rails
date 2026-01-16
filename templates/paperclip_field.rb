class AddPaperclipFieldsToGdpr < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_manager_portability_requests, :attachment, :string
    add_column :policy_manager_portability_requests, :attachment_file_name, :string
    add_column :policy_manager_portability_requests, :attachment_file_size, :string
    add_column :policy_manager_portability_requests, :attachment_file_content_type, :string
    add_column :policy_manager_portability_requests, :attachment_content_type, :datetime
  end
end
