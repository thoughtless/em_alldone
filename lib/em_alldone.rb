# Not a genuine Deferrable in that it doesn't include EM::Deferrable. Callbacks
# set will be run when all the passed in deferrables have completed with either
# success or failure. Doesn't support errbacks.
class EmAlldone
  module Version # :nodoc:
    STRING = '0.0.1'
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
