module Events
    class EventForm < BaseForm
      VirtusMixin = Virtus.model
      include VirtusMixin
      include ActiveModel::Validations
  
      attribute :name, String
      attribute :start_date, String
      attribute :start_time, String
      attribute :end_date, String 
      attribute :end_time, String 
      attribute :description, String
      attribute :google_calendar_id, String

      validates :name, presence: {message: "Event ame cannot be empty"}
      validates :start_date, presence: {message: "Start Date cannot be empty"}
      validates :end_date, presence: {message: "End Date cannot be empty"}
      validates :description, presence: {message: "Description cannot be empty"}
    end
  end
  