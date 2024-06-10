class EventDetailsController < ApplicationController
  before_action :set_event

  def new
    @users = User.all
  end

  def create
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
