require 'sinatra/base'
require 'sinatra/json'
require 'psych'

class PhoneNumberApi < Sinatra::Base
  # Responds with a 200 and list of all phone numbers known, regardless of order
  # or relation to a user
  get '/phone_numbers' do
    json phone_numbers: customers.flat_map { |customer| customer[:numbers] }
  end

  # Responds with either:
  # - 200 and list of phone numbers and their activation states for the requested customer
  # - 404 if customer is not found
  get '/customer/:id/phone_numbers' do
    if !(current = customer(params[:id].to_i)).nil?
      json phone_numbers: current[:numbers]
    else
      status 404
      json message: "could not find customer##{params[:id]}"
    end
  end

  # Writes to yaml with new state after reconstructing the db hash.
  # Responds with:
  # - 200 and success message
  # - 404 if customer not found or phone number not found in customer list
  #
  # Not too pleased with this, I think it could be nicer if I'd structured the Yaml
  # to reflect the actual tables and not a DB query reponse on both tables.
  post '/customer/:id/activate/:phone_number' do
    in_number = params[:phone_number].gsub('-',' ')
    if !(current = customer(params[:id].to_i)).nil?
      if current[:numbers].any? { |n| n[:number] == in_number }
        current[:numbers].map! { |n| n[:activated] = n[:number] == in_number ; n }
        db = customers.delete_if { |c| c[:id] == params[:id].to_i }
        db << current
        NoDB::save({ customers: db })
        json message: "Activated #{in_number}"
      else
        status 404
        json message: "Could not identify #{in_number} in customer##{params[:id]}'s list'."
      end
    else
      status 404
      json message: "could not find customer##{params[:id]}"
    end
  end

  def customer(id)
    customers.select { |customer| customer[:id] == id }.first
  end

  def customers
    NoDB::load[:customers]
  end
end

# This is WET because:
# 1) I enjoy typing
# 2) this would usually be ActiveRecord or something but there was a request not to use a DB?? :/
class NoDB
  class << self
    NODBFILE = './lib/mock_db.yml'

    def load
      @db ||= Psych::load(File::read(NODBFILE), symbolize_names: true)
    end

    def save(in_hash)
      File::open(NODBFILE, 'w') { |f| f.write(Psych.dump(in_hash)) }
    end
  end
end
