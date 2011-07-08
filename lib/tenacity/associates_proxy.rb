module Tenacity
  class AssociatesProxy #:nodoc:
    alias_method :proxy_respond_to?, :respond_to?
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

    def initialize(parent, target, association)
      @parent = parent
      @target = target
      @association = association
    end

    def respond_to?(*args)
      proxy_respond_to?(*args) || @target.respond_to?(*args)
    end

    # Explicitly proxy === because the instance method removal above doesn't catch it.
    def ===(other)
      other === @target
    end

    def <<(object)
      object._t_save_if_dirty unless @parent.id.nil?
      @target << AssociateProxy.new(object, @association)
    end

    def push(*objects)
      objects.each { |object| object._t_save_if_dirty } unless @parent.id.nil?
      proxies = objects.map { |object| AssociateProxy.new(object, @association) }
      @target.push(*proxies)
    end

    def concat(objects)
      objects.each { |object| object._t_save_if_dirty } unless @parent.id.nil?
      proxies = objects.map { |object| AssociateProxy.new(object, @association) }
      @target.concat(proxies)
    end

    def destroy_all
      remove_associates_from_parent
      @association.associate_class._t_delete(@parent._t_get_associate_ids(@association))
    end

    def delete_all
      remove_associates_from_parent
      @association.associate_class._t_delete(@parent._t_get_associate_ids(@association), false)
    end

    def inspect
      @target.inspect
    end

    private

    def remove_associates_from_parent
      @parent._t_remove_associates(@association)
      @parent._t_save_if_dirty
    end

    def method_missing(method, *args)
      if block_given?
        @target.send(method, *args) { |*block_args| yield(*block_args) }
      else
        @target.send(method, *args)
      end
    end
  end
end
