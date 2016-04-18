class ApiVersion
  def initialize(options={})
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/archiving.v#{@version}")
  end
end
