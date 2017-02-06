module Disburser
  module Utility
    def self.to_boolean(boolean)
      return true if boolean == true || boolean =~ (/(true|t|yes|y|1)$/i)
      return false if boolean == false || boolean.blank? || boolean =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("Invalid value for Boolean: \"#{boolean}\"")
    end
  end
end