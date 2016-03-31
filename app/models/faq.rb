# Faq entries are short instructions for using Archiving.
class Faq < ActiveRecord::Base
  establish_connection ARCHIVING_CONF

  validates :title, :body, presence: true

  # Runs the markdown and returns the html output
  #
  # @return [String] HTML output of body
  def pretty_body
    Archiving.markdown.render(body).html_safe
  end
end
