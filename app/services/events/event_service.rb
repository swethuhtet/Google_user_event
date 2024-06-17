module Events 
  class EventService
    def initialize(params)
      @params = params
    end
  
      #CREATE
      def create(user_ids)
        event = Event.new(@params.except(:start_time,:end_time))
        event.set_datetimes(
          start_date: @params[:start_date],
          start_time: @params[:start_time],
          end_date: @params[:end_date],
          end_time: @params[:end_time]
        )
        byebug
        if event.save
          EventDetails::EventDetailUsecase.new.create_event_details(event, user_ids)

          handle_calendar_details(user_ids,event)

          return {event: event, status: :created}
        else 
          return {event: event,notice:"Create event error", status: :unprocessable_entity}
        end
      end
      
      #UPDATE
      def update(updated_event,user_ids)
        
        updated_event.set_datetimes(
          start_date: @params[:start_date],
          start_time: @params[:start_time],
          end_date: @params[:end_date],
          end_time: @params[:end_time]
          )
          
        if updated_event.update(@params.except(:start_date, :start_time, :end_date, :end_time))
          EventDetails::EventDetailUsecase.new.update_event_details(updated_event,user_ids)

          handle_calendar_update(updated_event)

          return {event: updated_event, status: :updated}
        else
          return {event: updated_event, status: :unprocessable_entity}
        end
      end
  
      #DELETE
      def destroy(deleted_event)
        event = Event.find(deleted_event[:id])
        if event.destroy

          handle_calendar_delete(deleted_event)

          return true
        else
          return false
        end
      end
      
    private
      
    #new google calendar
    def new_google_calendar(user,event)
      google_event = build_google_event(event)
      GoogleService.new(user).create_event(google_event)
    end

    #updating google calendar
    def update_google_calendar(event_detail,updated_event)
      user = User.find(event_detail.user_id)

      google_event = build_google_event(updated_event)
      GoogleService.new(user).update_event(event_detail, google_event)
    end

    def build_google_event(event)
      Google::Apis::CalendarV3::Event.new(
        summary: event.name,
        description: event.description,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.start_date.iso8601,  
          time_zone: 'Asia/Yangon'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: event.end_date.iso8601,  
          time_zone: 'Asia/Yangon'
        )
      )
    end

    def handle_calendar_details(user_ids,event)
      user_ids.each do |user_id|
        user=User.find(user_id)
        return unless user.google_token.present?
          google_event_result = new_google_calendar(user,event)

          eventdetail = EventDetail.find_by( event_id: event.id, user_id: user_id )
          eventdetail.update!(google_calendar_id: google_event_result.id) 
      end
    end

    def handle_calendar_update(updated_event)
      updated_event.event_details.each do |event_detail|
        if event_detail.google_calendar_id.present?
          update_google_calendar(event_detail, updated_event)
        else
          new_user_on_update(event_detail.user_id,updated_event)
        end
      end
    end

    def handle_calendar_delete(deleted_event)
      deleted_event.event_details.each do |event_detail|
        user = User.find(event_detail.user_id)

        GoogleService.new(user).delete_event(event_detail)
      end
    end

    #for new user on update
    def new_user_on_update(user_id,updated_event)
      new_user = User.find(user_id)
      
      if new_user.google_token.present?
        google_event = build_google_event(updated_event)
        google_event_result = GoogleService.new(new_user).create_event(google_event)

        eventdetail = EventDetail.find_by( event_id: updated_event.id, user_id: user_id )
        eventdetail.update!(google_calendar_id: google_event_result.id) 
      end
    end
    
  end
end
