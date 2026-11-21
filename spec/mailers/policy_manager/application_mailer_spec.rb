require 'spec_helper'

describe PolicyManager::ApplicationMailer do
  let(:mailer_file) { PolicyManager::Engine.root.join('app/mailers/policy_manager/application_mailer.rb').to_s }

  around do |example|
    previous = PolicyManager::Config.exporter
    example.run
    PolicyManager::Config.class_variable_set(:@@exporter, previous)
  end

  ['UserHelper', UserHelper].each do |mail_helper|
    it "registers #{mail_helper.inspect} as a mailer helper" do
      PolicyManager::Config.exporter = { mail_helpers: [mail_helper] }
      load mailer_file
      expect(described_class._helpers.ancestors).to include(UserHelper)
    end
  end
end
