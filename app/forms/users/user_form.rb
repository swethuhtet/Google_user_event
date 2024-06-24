module Users
  class UserForm < BaseForm
    VirtusMixin = Virtus.model
    include VirtusMixin
    include ActiveModel::Validations

    attribute :firstname, String
    attribute :lastname, String
    attribute :email, String
    attribute :encrypted_password, String 
    attribute :gender, Integer, :defaults => 0
    attribute :about_me, String
    attribute :profile, String

    validates :firstname, presence: {message: "First name cannot be empty"}
    validates :lastname, presence: {message: "Last name cannot be empty"}
    validates :email, presence: {message: "Email cannot be empty"}
    validates :encrypted_password, presence: {message: "Password cannot be empty"}
    validates :about_me, presence: {message: "About me cannot be empty"}
    validates :gender, presence: {message: "Gender cannot be empty"}
    
  end
end
