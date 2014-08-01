# Not a genuine Deferrable in that it doesn't include EM::Deferrable. Callbacks
# set will be run when all the passed in deferrables have completed with either
# success or failure. Doesn't support errbacks.
class EmAlldone
  module Version # :nodoc:
    STRING = '0.0.2'
  end

  # This is a super simple implementation of EM::DefaultDeferrable.
  # This is used so we don't need to explicitly depend upon the EventMachine gem.
  # This is not meant for external use.
  class BasicDeferrable # :nodoc:
    # Does nothing
    def errback; end
    def fail(*args); end

    # If the callback arguments are set (i.e. `succeed` has been called),
    # then the given callback will be run immediately.
    def callback &block
      @callback = block
      if @callback_args
        @callback.call *@callback_args
      end
      self
    end

    # If the callback is set, then it will be run.
    # Otherwise we save the arguments for later.
    def succeed(*args)
      if @callback
        @callback.call(*args)
      else
        @callback_args = args
      end
    end
  end



  # Returns an instance. However, it ensures that when the callback is called
  # it is called with the specified arguments.
  def self.with(deferrables, *args, &block)
    deferrables = deferrables.flatten
    deferrables << BasicDeferrable.new
    deferrables[-1].succeed *args
    new(deferrables, &block)
  end

  def initialize(*deferrables, &block)
    deferrables = deferrables.flatten
    raise ArgumentError, "Must provide at least one argument" unless deferrables.size > 0
    deferrables.each do |d|
      raise ArgumentError, "All arguments must be deferrables, but #{d.inspect} doesn't." unless d.respond_to?(:callback) && d.respond_to?(:errback)
    end

    @deferrable = deferrables[-1]

    if deferrables.size > 1
      @recurse = EmAlldone.new deferrables[0...-1]
    end

    self.callback &block if block
  end

  def callback &block
    current_proc = Proc.new do
      @deferrable.callback &block
      @deferrable.errback  &block
    end

    if @recurse
      @recurse.callback &current_proc
    else
      current_proc.call
    end
  end
end
