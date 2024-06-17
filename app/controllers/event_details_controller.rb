class EventDetailsController < ApplicationController
  before_action :set_event

  def new
    @users = User.all
    @assigned_users = @event.event_details.pluck(:user_id) 
  end
  
  def create
    user_ids = params[:user_ids].map(&:to_i).reject(&:zero?)
    assigned_users = @event.event_details.pluck(:user_id) 

    new_users_ids = user_ids - assigned_users
    
    logger.debug "User IDs: #{new_users_ids.inspect}"

    ActiveRecord::Base.transaction do
      new_users_ids.each do |user_id|
        event_detail = EventDetail.create(event_id: @event.id, user_id: user_id)
        unless event_detail.persisted?
          logger.error "Failed to create EventDetail for event #{@event.id} and user #{user_id}"
          raise ActiveRecord::Rollback
        end
      end
      redirect_to event_path(@event), notice: 'Users successfully added to the event.'
    rescue ActiveRecord::Rollback
      redirect_to new_events_event_path(@event), alert: 'Failed to add users to the event.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

end
