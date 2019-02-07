module PolicyManager
  class ExporterJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      user_model = if Config.user_resource.is_a?(String)
        Config.user_resource.constantize
      else
        Config.user_resource
      end
      user = user_model.find(user_id)
      Config.exporter.perform(user)
    end
  end
end
