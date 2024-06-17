class AddGoogleCalendarIdToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :google_calendar_id, :string
  end
end
