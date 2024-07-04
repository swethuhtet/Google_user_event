require 'csv'

class Guest < ApplicationRecord
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
          guest_params = row.to_hash
          Guest.create!(guest_params)
        end
    end
end
