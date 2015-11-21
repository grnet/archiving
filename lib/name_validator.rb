class NameValidator < ActiveModel::Validator
  def validate(record)
    unless record.name =~ /^[a-zA-Z0-1\.-_ ]+$/
      record.errors[:name] << "Can only contain numbers, letters, space, '.', '-' and '_'"
    end
  end
end
