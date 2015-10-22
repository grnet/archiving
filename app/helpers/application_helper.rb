module ApplicationHelper
  # Custom helper for better display of big numbers
  # @example number_by_magnitude(4242)
  #  "4.2K"
  #
  # @param number[Numeric]
  # @return [String] human friendly respresentation
  def number_by_magnitude(number)
    number_to_human(number, units: { thousand: :K, million: :M, billion: :G })
  end
end
