require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'Eastern Time (US & Canada)'
  config.gem "bluecloth"
  config.action_controller.session_store = :active_record_store
end
