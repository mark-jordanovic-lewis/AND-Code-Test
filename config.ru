require_relative 'lib/phone_number_api.rb'

run Rack::Cascade::new [PhoneNumberApi]
