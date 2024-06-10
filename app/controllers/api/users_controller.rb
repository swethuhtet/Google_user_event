require_relative '../../services/users/user_service.rb'
class Api::UsersController < Api::ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_user, only: [ :show, :update, :destroy ]

  # GET ALL
  def index
    users = User.all
    render json: users, each_serializer: UserSerializer, status: :ok
  end

  # SHOW
  def show
    render_user_json(@user, :ok)
  end

  # CREATE
  def create
    create_user = Users::UserUsecase.new(user_params)
    if create_user.create[:status] == :created
      render json: { message: "User was successfully created.", status: :created }
    else
      render json: create_user.create[:errors], status: :unprocessable_entity
    end
  end

  # UPDATE
  def update
    update_user = Users::UserUsecase.new(user_params)
    response = update_user.update(@user)
    if response[:status] == :updated 
      render json: { message: "User was successfully updated.", status: :updated }
    else
      render json: response[:errors], status: :unprocessable_entity
    end
  end
  
  # DELETE
  def destroy 
    deleted_user = Users::UserUsecase.new(nil)
    if deleted_user.destroy(@user)
      render json: { message: "User was successfully deleted.", status: :ok }
    else
      render json: { message: "Something wrong in user update." }, status: :unprocessable_entity
    end
  end

  private
  # CALLBACKS
  def set_user
    @user = User.find(params[:id])
  end

  # TRUSTED PARAMS
  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :encrypted_password, :about_me, :gender, :profile, :image_url)
  end

  # To call the serializer
  def render_user_json(user_param, status = :ok)
    render json: user_param, serializer: UserSerializer, status: status
  end

end

