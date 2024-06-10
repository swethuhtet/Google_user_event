class BaseForm
  VirtusMixin = Virtus.model
  include VirtusMixin
  include ActiveModel::Validations
  
  attribute :id, Integer
end
  