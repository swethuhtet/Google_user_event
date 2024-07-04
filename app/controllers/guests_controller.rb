class GuestsController < ApplicationController
  def index
    @guests = Guest.all()
    
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@guests), filename: "guests-#{Date.today}.csv" }
    end
  end

  def new_import
  end

  def import
    if params[:file].present?
      Guest.import(params[:file])
      redirect_to guests_path, notice: "CSV file imported successfully."
    else
      redirect_to new_import_guests_path, alert: "Please upload a CSV file."
    end
  end

  private

  def generate_csv(guests)
    CSV.generate(headers: true) do |csv|
      csv << ['Name', 'Age', 'City']
      
      guests.each do |guest|
        csv << [guest.name, guest.age, guest.city]
      end
    end
  end
end
