module Users 
  class UserService
    def initialize(params)
      @params = params
    end

    #CREATE
    def create
      user = User.new(@params)
      if user.save
        return {user: user, status: :created}
      else 
        return {user: user,notice:"Create error", status: :unprocessable_entity}
      end
    end
    
    #UPDATE
    def update(updated_user)
      if updated_user.update(@params)
        return {user: updated_user, status: :updated}
      else
        return {user: updated_user, status: :unprocessable_entity}
      end
    end

    #DELETE
    def destroy(deleted_user)
      user = User.find(deleted_user[:id])
      if user.destroy
        return true
      else
        return false
      end
    end
  end
end