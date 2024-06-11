module Events 
    class EventService
      def initialize(params)
        @params = params
      end
  
      #CREATE
      def create
        event = Event.new(@params.except(:start_time,:end_time))
        event.set_datetimes(
          start_date: @params[:start_date],
          start_time: @params[:start_time],
          end_date: @params[:end_date],
          end_time: @params[:end_time]
        )
        if event.save
          return {event: event, status: :created}
        else 
          return {event: event,notice:"Create event error", status: :unprocessable_entity}
        end
      end
      
      #UPDATE
      def update(updated_event)
        updated_event.set_datetimes(
          start_date: @params[:start_date],
          start_time: @params[:start_time],
          end_date: @params[:end_date],
          end_time: @params[:end_time]
        )
        if updated_event.update(@params.except(:start_time,:end_time))
          return {event: updated_event, status: :updated}
        else
          return {event: updated_event, status: :unprocessable_entity}
        end
      end
  
      #DELETE
      def destroy(deleted_event)
        event = Event.find(deleted_event[:id])
        if event.destroy
          return true
        else
          return false
        end
      end
    end
  end