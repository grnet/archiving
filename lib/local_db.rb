module LocalDb
  establish_connection "local_#{Rails.env}".to_sym
end
