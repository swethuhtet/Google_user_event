require_relative '../../forms/users/user_form.rb'
module Users
  class UserUsecase < BaseUsecase
    def initialize(params)
      @params = params
      @form = Users::UserForm.new(params)
    end
    
    #CREATE
    def create
      begin
        user_create_service = Users::UserService.new(@form.attributes)
        if @form.valid?
          response = user_create_service.create
          if response[:status] == :created 
            return {user: response[:user], status: :created}
          end
        else
          @user = User.new(@form.attributes)
          return {user: @user, errors: @form.errors, notice:"Create error",status: :unprocessable_entity}
        end
      rescue StandardError => errors
        return {user: @user, errors: errors.message, status: :unprocessable_entity}
      end    
    end

    #UPDATE
    def update(updated_user)
      begin
        if @form.valid?
          user_update_service = Users::UserService.new(@params)
          response = user_update_service.update(updated_user)

          if response[:status] == :updated
            return {user: response[:user], status: :updated}
          end
        else
          @user = User.new(@form.attributes)
          return {user: @user, errors: @form.errors, status: :unprocessable_entity}
        end
      rescue StandardError => errors
        return {user: @user, errors: errors.message, status: :unprocessable_entity}
      end
    end

    #DELETE
    def destroy(deleted_user)
      begin
        user_delete_service = Users::UserService.new(@params)
        if user_delete_service.destroy(deleted_user)
          return true
        else
          return false
        end
      rescue StandardError => errors
        return {errors: errors.message}
      end
    end

  end
end
