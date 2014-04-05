# Object.try method
class Object
  def try(method, *args, &block)
    send(method, *args, &block)
  end
end

class NilClass
  def try(method, *args, &block)
    nil
  end
end
# <-- end

unless (RUBY_VERSION[0,3] == '1.9')
  module Enumerable
    # Enumerable#none? is the logical opposite of the builtin method
    # Enumerable#any?.  It returns +true+ if and only if _none_ of
    # the elements in the collection satisfy the predicate.
    #
    # If no predicate is provided, Enumerable#none? returns +true+
    # if and only if _none_ of the elements have a true value
    # (i.e. not +nil+ or +false+).
    #
    #   [].none?                      # true
    #   [nil].none?                   # true
    #   [5,8,9].none?                 # false
    #   (1...10).none? { |n| n < 0 }  # true
    #   (1...10).none? { |n| n > 0 }  # false
    #
    # CREDIT: Gavin Sinclair

    def none?  # :yield: e
      if block_given?
        not self.any? { |e| yield e }
      else
        not self.any?
      end
    end
  end
end

#open_id_authentication fix for rails 2.1.0
OpenIdAuthentication.module_eval '
  private

  def requested_url
    relative_url_root = self.class.respond_to?(:relative_url_root) ?
      self.class.relative_url_root.to_s :
      request.relative_url_root
#      "#{request.protocol}#{request.host_with_port}#{ActionController::Base.relative_url_root}#{request.path}" # original
    "#{request.protocol + request.host_with_port + relative_url_root + request.path}"
  end
'
