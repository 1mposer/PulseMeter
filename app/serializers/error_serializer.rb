class ErrorSerializer
  def self.from_active_record(model)
    { errors: model.errors.full_messages }
  end

  def self.from_messages(*msgs)
    { errors: msgs.flatten }
  end
end
