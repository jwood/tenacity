module Tenacity
  class AssociateProxy #:nodoc:
    alias_method :proxy_respond_to?, :respond_to?
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

    def initialize(target, association)
      raise "Cannot create a Tenacity::AssociateProxy with a nil target" if target.nil?
      @target = target
      @association = association
      @marked_for_destruction = false
    end

    def respond_to?(*args)
      proxy_respond_to?(*args) || @target.respond_to?(*args)
    end

    # Explicitly proxy === because the instance method removal above doesn't catch it.
    def ===(other)
      other === @target
    end

    def inspect
      @target.inspect
    end

    def save
      if @association.readonly?
        raise ReadOnlyError
      else
        @target.save
      end
    end

    def association_target
      @target
    end

    def mark_for_destruction
      @marked_for_destruction = true
    end

    def marked_for_destruction?
      @marked_for_destruction
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
