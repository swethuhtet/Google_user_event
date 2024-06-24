module EventDetails
  class EventDetailUsecase < BaseUsecase
    def initialize
    end
    
    #to handle in adding new user to event
    def create_event_details(event,user_ids)
      user_ids.each do |user_id|
        EventDetail.create(event_id: event.id, user_id: user_id)
      end
    end

    #to handle in update event case
    def update_event_details(updated_event,user_ids)
      
      old_user_ids = updated_event.event_details.pluck(:user_id)
        
      new_user_ids = user_ids - old_user_ids
      new_user_ids.each do |user_id|
        EventDetail.create(event_id: updated_event.id, user_id: user_id)
      end
        
      removed_user_ids = old_user_ids - user_ids
      users = User.find(removed_user_ids)

      users.each do |user|
        event_detail = EventDetail.find_by(event_id: updated_event.id, user_id: user.id)
        GoogleService.new(user).delete_event(event_detail)
      end

      EventDetail.where(event_id: updated_event.id, user_id: removed_user_ids).destroy_all
    end
  end
end
