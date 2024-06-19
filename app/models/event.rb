class Event < ApplicationRecord
    has_many :event_details , dependent: :destroy 
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

    def start_time
      start_date&.strftime("%H:%M")
    end
    
    def end_time
      end_date&.strftime("%H:%M")
    end

    def status
      current_time = Time.current
  
      if start_date.nil? || end_date.nil?
        'New event'
      elsif start_date > current_time
        'Upcoming'
      elsif start_date <= current_time && end_date >= current_time
        'Ongoing'
      elsif end_date < current_time
        'Ended'
      else
        'Unknown' 
      end
    end

    private

    def combine_datetime(date, time)
      return nil if date.blank? || time.blank?
      "#{date} #{time}"
    end
end
