require 'psych'

class MockDB
  attr_reader :db_hash
  def initialize
    @db_hash = Psych::load(File::read('./spec/support/mock_db.yml'))
  end
end
