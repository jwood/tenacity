module Tenacity
  class AssociatesProxy #:nodoc:
    alias_method :proxy_respond_to?, :respond_to?
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

    def initialize(parent, target)
      @parent = parent
      @target = target
    end

    def respond_to?(*args)
      proxy_respond_to?(*args) || @target.respond_to?(*args)
    end

    # Explicitly proxy === because the instance method removal above doesn't catch it.
    def ===(other)
      other === @target
    end

    def <<(object)
      object.save unless @parent.id.nil?
      @target << object
    end

    private

    def method_missing(method, *args)
      if block_given?
        @target.send(method, *args) { |*block_args| yield(*block_args) }
      else
        @target.send(method, *args)
      end
    end
  end
end
