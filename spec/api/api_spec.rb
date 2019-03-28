require 'spec_helper'

describe 'PhoneNumberApi' do
  include Rack::Test::Methods
  let(:app) { PhoneNumberApi::new }
  let(:mock_db) { MockDB::new }
  after(:each) do # Tidy up as spec alters mock db file, usually use some DB Cleaning util.
    File::open('./lib/mock_db.yml', 'w') { |f| f.write File::read('./spec/support/mock_db.yml') }
  end
  # Retrieving the list of all phone numbers
  describe 'GET /phone_numbers' do
    let(:numbers) do
      mock_db
        .db_hash['customers']
        .each_with_object([]) { |customer,number_list| number_list << customer['numbers'] }
        .flatten
    end
    it 'returns all stored phone numbers' do
      aggregate_failures do
        [1,2].each do |id|
          get "http://localhost/phone_numbers"
          payload = JSON::parse(last_response.body)
          expect(payload).to eq({ 'phone_numbers' => numbers })
        end
      end
    end
  end

  # Retrieving a list of all phone numbers for a customer
  describe 'GET /customer/:id/phone_numbers' do
    it 'returns all phone numbers held by a particular customer' do
      aggregate_failures do
        [1,2].each do |id|
          get "http://localhost/customer/#{id}/phone_numbers"
          payload = JSON::parse(last_response.body)
          customer_numbers = mock_db.db_hash['customers'].select { |c| c['id'] == id }[0]['numbers']
          expect(payload).to eq({'phone_numbers' => customer_numbers})
        end
      end
    end

    it 'returns an error 404 if customer is not known' do
      get "http://localhost/customer/42/phone_numbers"
      expect(last_response.status).to eq 404
    end
  end

  # activating a phone number
  describe 'POST /customer/:id/activate/:phone_number' do
    # could have used json params here, tbh I would prefer to have but embedded url params for sinatra work just as well
    it 'sets the requested number as `activated: true`' do
      aggregate_failures do
        [[1,'0161 123 1234'],[2,'0161 123 4567']].each do |(id,number)|
          post "http://localhost/customer/#{id}/activate/#{number.gsub(' ','-')}"
          expect(last_response.status).to eq 200

          get "/customer/#{id}/phone_numbers"
          active_number = JSON::parse(last_response.body)['phone_numbers'].select { |n| n['number'] == number }[0]
          expect(active_number['activated']).to be true
        end
      end
    end

    it 'returns an error 404 if customer does not know phone number' do
      post "http://localhost/customer/2/activate/0161-123-9999"
      expect(last_response.status).to eq 404
    end

    it 'returns an error 404 if customer is not known' do
      post "http://localhost/customer/42/activate/0161-123-9999"
      expect(last_response.status).to eq 404
    end
  end
end
