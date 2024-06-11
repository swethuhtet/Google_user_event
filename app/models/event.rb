class Event < ApplicationRecord
    has_many :event_details
    validate :end_date_after_start_date

    def end_date_after_start_date
        return if end_date.blank? || start_date.blank?
    
        if end_date < start_date
          errors.add(:end_date, "must be after the start date")
        end
    end
    
    def set_datetimes(start_date:,start_time:,end_date:,end_time:)
      self.start_date = combine_datetime(start_date,start_time) 
      self.end_date = combine_datetime(end_date,end_time) 
    end

    private

    def combine_datetime(date, time)
      return nil if date.blank? || time.blank?
      "#{date} #{time}"
    end
end
