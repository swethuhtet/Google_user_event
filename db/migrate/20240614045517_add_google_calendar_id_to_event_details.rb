class AddGoogleCalendarIdToEventDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :event_details, :google_calendar_id, :string
  end
end
