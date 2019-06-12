# -*- encoding : utf-8 -*-
require "paperclip"

module PolicyManager::Concerns::PaperclipBehavior
  extend ActiveSupport::Concern
  include Paperclip::Glue

  included do

    has_attached_file :attachment,
      path: Config.exporter.try(:attachment_path) || Rails.root.join("tmp/portability/:id/build.zip").to_s,
      storage: Config.exporter.try(:attachment_storage) || :filesystem,
      s3_permissions: :private

    do_not_validate_attachment_file_type :attachment
  end

  def file_remote_url=(url_value)
    self.attachment = File.open(url_value) unless url_value.blank?
    self.save
    self.complete!
  end

  def download_link
    url = self.attachment.expiring_url(PolicyManager::Config.exporter.expiration_link)
    PolicyManager::Config.exporter.customize_link(url)
  end
end