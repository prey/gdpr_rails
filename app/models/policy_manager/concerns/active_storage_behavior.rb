module PolicyManager::Concerns::ActiveStorageBehavior
  extend ActiveSupport::Concern

  included do
    has_one_attached :attachment
  end

  def file_remote_url=(url_value)
    unless url_value.blank?
      attachment.attach(
        io: File.open(url_value),
        filename: File.basename(url_value),
        content_type: 'application/zip'
      )
    end

    # self.attachment = File.open(url_value) unless url_value.blank?

    save
    complete!
  end

  def download_link
    return '' unless attachment.attached?

    url = Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
    # self.attachment.expiring_url(PolicyManager::Config.exporter.expiration_link)
    PolicyManager::Config.exporter.customize_link(url)
  end
end
