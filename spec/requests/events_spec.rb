require 'rails_helper'

RSpec.describe "Events API", type: :request do
    describe 'GET /events' do
      it 'returns a list of events' do
        get '/events'
        expect(response).to have_http_status(:success)
      end

      it 'return Google event lists' do 
        user = User.first
        google_client = GoogleService.new(user).setup_google_client
        events = google_client.list_events('primary')
        
        expect(events.items.count).not_to eq(0)
      end
    end

    describe 'GET /events/:id' do
      it 'returns the event' do 
        existing_event = Event.first
        
        get "/events/#{existing_event.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /events' do 
      let (:valid_event_params) do 
        {
          event:{
            name: "Event Name",
            start_date: "2024-06-25",
            start_time: "10:00",
            end_date: "2024-06-25",
            end_time: "12:00",  
            description: "This is a test event.",
            google_calendar_id: ""
          },
          user_ids: [1]
        }
      end
      let (:invalid_event_params) do 
        {
          event:{
            name: "",
            start_date: "",
            start_time: "",
            end_date: "",
            end_time: "",  
            description: "",
            google_calendar_id: ""
          },
          user_ids: [1]
        }
      end
      
      context 'when creating a valid user' do 
        it 'create a new event' do 
          expect {
            post '/events', params: valid_event_params
          }.to change(Event, :count).by(1)
          
          expect(response).to have_http_status(:found)
        end
        
        it 'create a new event in Google calendar' do 
          user = User.first
          google_client = GoogleService.new(user).setup_google_client
          before_events = google_client.list_events('primary')
          before_count = before_events.items.count
          
          post '/events', params: valid_event_params
          
          google_client = GoogleService.new(user).setup_google_client
          after_events = google_client.list_events('primary')
          after_count = after_events.items.count

          expect(after_count).to eq(before_count + 1)
        end
      end
      
      context 'when creating a invalid event' do
        it 'returns validation errors' do 
          expect {
            post '/events', params: invalid_event_params, headers: {'ACCEPT'=> 'application/json'}
          }.not_to change(Event, :count)
          
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'returns an error if event name is blank' do
          name_empty = valid_event_params.deep_merge(event: { name: "" })
  
          expect {
            post '/events', params: name_empty, headers: { 'ACCEPT' => 'application/json' }
          }.not_to change(Event, :count)
  
          expect(response).to have_http_status(:unprocessable_entity)
  
          json_response = JSON.parse(response.body)
          expect(json_response).to include("errors")  
          expect(json_response["errors"]["name"]).to include("Event name cannot be empty")
        end
      end

    end

    describe 'PATCH /events/:id' do 
      let (:existing_event) {Event.first}
      context 'when updating an existing event' do 
        it 'update the event' do 
          updated_params={
              event:{
              name: "Updated Event Name",
              start_date: "2024-06-25",
              start_time: "13:00",
              end_date: "2024-06-25",
              end_time: "17:00",  
              description: "This is a test event updated values.",
              google_calendar_id: ""
            },
            user_ids: [1]
          }

          patch "/events/#{existing_event.id}", params: updated_params

          expect(response).to have_http_status(:found)
          
          updated_event = existing_event.reload
          expect(updated_event.name).to eq("Updated Event Name")
          expect(updated_event.description).to eq("This is a test event updated values.")
        end

        it 'update the event in Google calendar' do
          updated_params={
            event:{
              name: "Updated Event Name",
              start_date: "2024-06-25",
              start_time: "13:00",
              end_date: "2024-06-25",
              end_time: "17:00",  
              description: "This is a test event updated values.",
              google_calendar_id: ""
            },
            user_ids: [1]
          } 
          patch "/events/#{existing_event.id}", params: updated_params

          expect(response).to have_http_status(:found)
          
          updated_events = []
          user = User.first
          existing_event.event_details.each do |event_detail|
            google_client = GoogleService.new(user).setup_google_client
            updated_event = google_client.get_event('primary',event_detail.google_calendar_id)
            updated_events << updated_event
          end

          updated_events.each do |event|
            expect(event.summary).to eq("Updated Event Name")
            expect(event.description).to eq("This is a test event updated values.")
          end
        end

        it 'returns error if event name is blank' do
          invalid_params={
            event:{
              name: "",
              start_date: "2024-06-25",
              start_time: "13:00",
              end_date: "2024-06-25",
              end_time: "17:00",  
              description: "This is a test event updated values.",
              google_calendar_id: ""
            },
            user_ids: [1]
          }
  
          patch "/events/#{existing_event.id}", params: invalid_params, headers: { 'ACCEPT' => 'application/json' }
          
          expect(response).to have_http_status(:unprocessable_entity)
          
          json_response = JSON.parse(response.body)
          expect(json_response).to include("errors")  
          expect(json_response["errors"]["name"]).to include("Event name cannot be empty")
        end
      end

      context 'when the event does not exist' do 
        it 'return not found status' do 
          invalid_event_id = existing_event.id + 1000

          patch "/events/#{invalid_event_id}"
          
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe 'DELETE /events/:id' do 
      let (:existing_event) {Event.first}
      context 'when deleting an existing event' do 
        it 'deletes the event' do
          expect {
            delete "/events/#{existing_event.id}"
          }.to change(Event, :count).by(-1)
  
          expect(response).to redirect_to(events_url)
          follow_redirect!
          
          expect(flash[:notice]).to eq(I18n.t('messages.common.destroy_success', data: "Event"))
        end

        it 'deletes the event in Google calendar' do 
          delete "/events/#{existing_event.id}"
          
          user = User.first
          existing_event.event_details.each do |event_detail|
            google_client = GoogleService.new(user).setup_google_client
            begin
              google_client.get_event('primary',event_detail.google_calendar_id)
              fail 'Event should be deleted but still exists'
            rescue Google::Apis::ClientError => e
              expect(e.status_code).to eq(404) 
            end
          end
        end
      end

      context 'when event does not exist' do 
        it 'returns not found status' do
          delete "/events/#{existing_event.id + 1000}" 
  
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('Event not found')
        end
      end
    end
end