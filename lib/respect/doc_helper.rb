module Respect
  # Convenient module to ease usage of {DocParser}.
  #
  # Include it in classes returning their documentation via a +documentation+ method.
  # This module provides a {#title} and {#description} methods for extracting
  # them from the documentation.
  module DocHelper
    # Returns the title part of the documentation returned by +documentation+ method
    # (+nil+ if it does not have any).
    def title
      if documentation
        DocParser.new.parse(documentation.to_s).title
      end
    end

    # Returns the description part of the documentation returned by +documentation+ method
    # (+nil+ if it does not have any).
    def description
      if documentation
        DocParser.new.parse(documentation.to_s).description
      end
    end
  end
end # module Respect
