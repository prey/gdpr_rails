module PolicyManager
  class ExporterJob < ApplicationJob
    queue_as :default
   
    def perform(user_id)
      user = User.find(user_id)
      Config.exporter.perform(user)
    end
  end
end