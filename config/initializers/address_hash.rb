require 'singleton'

class IPLocation < Hash
  include Singleton

  def initialize
    super([])
  end

  # def add src
  #   src.to_s.split(";").each do |item|
  #     splitted = item.split("=")
  #     self[splitted[0]] = splitted[1]
  #   end
  # end
end