  class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  
  # GET ALL
  def index
    @users = User.all
  end

  # SHOW
  def show
  end

  # NEW
  def new
    @user = User.new(flash[:user_attributes] || {})
    @user.errors.add(:base, flash[:errors]) if flash[:errors].present?
  end

  # EDIT
  def edit
  end

  # CREATE
  def create
    respond_to do |format|
      begin
        @user = Users::UserUsecase.new(user_params)
        response = @user.create
        if response[:status] == :created
          format.html { redirect_to users_path(@user), notice: "User was successfully created." }
          format.json { render :show, status: :created, location: @user }
        else
          flash[:errors] = response[:error]
          format.html { redirect_to new_user_path, notice: "User field are empty or wrong type.", status: :unprocessable_entity}
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      rescue StandardError => e
        logger.error "There is something wrong with creating user. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  # UPDATE
  def update
    updated_user = User.find(params[:id])
    @user = Users::UserUsecase.new(user_params)
    respond_to do |format|
      if @user.update(updated_user)
        format.html { redirect_to users_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE
  def destroy
    @deleted_user = Users::UserUsecase.new(nil)

    respond_to do |format|
      if @deleted_user.destroy(@user)
        format.html { redirect_to users_url, notice: t('messages.common.destroy_success', data: "User") }
        format.json { head :no_content }
      end
    end
  end

  private
    # CALLBACKS
    def set_user
      @user = User.find(params[:id])
    end

    # TRUSTED PARAMS
    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :encrypted_password, :about_me,:gender, :profile)
    end
end
