require 'aasm'

module PolicyManager
  class PortabilityRequest < ApplicationRecord
    belongs_to :user, class_name: Config.user_resource.to_s, foreign_key: :user_id

    include PolicyManager::Concerns::ActiveStorageBehavior

    include AASM

    aasm column: :state do
      state :pending, initial: true, after_enter: :notify_progress_to_admin
      state :progress, after_enter: :handle_progress
      state :completed, after_enter: :notify_completeness

      event :confirm do
        transitions from: :pending, to: :progress
      end

      event :complete do
        transitions from: :progress, to: :completed
      end
    end

    def user_email
      user.email
    end

    def handle_progress
      notify_progress
      perform_job
    end

    def perform_job
      ExporterJob.set(queue: :default).perform_later(user.id)
    end

    def notify_progress
      PortabilityMailer.progress_notification(id).deliver_now
    end

    def notify_progress_to_admin
      PortabilityMailer.admin_notification(user.id).deliver_now
    end

    def notify_completeness
      PortabilityMailer.completed_notification(id).deliver_now
    end
  end
end
