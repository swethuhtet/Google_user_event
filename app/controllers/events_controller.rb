class EventsController < ApplicationController
  #GET ALL
  def index
    @events = Event.all
  end

  #SHOW
  def show
    @event = Event.find(params[:id])
  end
  
  #NEW
  def new
    @event = Event.new
  end

  #CREATE
  def create
    respond_to do |format|
      begin
        @event = Events::EventUsecase.new(event_params)
        @event.start_date = combine_datetime(params[:event][:start_date],params[:event][:start_time])
        @event.end_date = combine_datetime(params[:event][:end_date],params[:event][:end_time])
        response = @event.create

        if response[:status] == :created
          format.html { redirect_to events_path(@event), notice: "Event was successfully created." }
          format.json { render :show, status: :created, location: @event }
        else
          flash[:errors] = response[:error]
          format.html { redirect_to new_event_path, notice: "Event field are empty or wrong type.", status: :unprocessable_entity}
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      rescue StandardError => e
        logger.error "There is something wrong with creating event. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  private

  def combine_datetime(date, time)
    return nil if date.blank? || time.blank?
    "#{date} #{time}"
  end

  def event_params
    params.require(:event).permit(:name, :start_date, :start_time, :end_date, :end_time, :description)
  end
end
