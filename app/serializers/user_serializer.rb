class UserSerializer < ActiveModel::Serializer
  attributes :id, :firstname, :lastname, :email, :encrypted_password, :about_me, 
  :gender, :profile,:created_at, :updated_at, :image_url
  
  def attributes(*args)
    hash = super
    hash.except!(:profile)
    hash
  end

  def gender
    if object.gender == 0
      "Male"
    else
      "Female"
    end
  end
  
  def created_at
    formated_created_at = object.created_at.strftime("%m-%d-%y")
  end

  def updated_at
    formated_updated_at = object.updated_at.strftime("%m-%d-%y")
  end
end
