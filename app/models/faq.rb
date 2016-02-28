# Faq entries are short instructions for using Archiving.
class Faq < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  validates :title, :body, presence: true

end
