require 'zk'

class ZK::PersistentLock
  attr_reader :key

  class << self
    attr_accessor :hosts
    attr_accessor :timeout
    attr_accessor :sleep
    attr_accessor :expire
    attr_accessor :namespace
  end

  self.timeout   = 60
  self.expire    = 60
  self.sleep     = 0.1
  self.namespace = 'zk-persistent-lock'

  attr_accessor :key

  def initialize(key, options={})
    raise "key cannot be nil" if key.nil?
    @root = "/" + (options[:namespace] || self.class.namespace)
    @key =  @root + "/" + key

    @zk = ZK.new(self.class.hosts || options[:hosts] || 'localhost:2181')

    @timeout = options[:timeout] || self.class.timeout
    @expire  = options[:expire]  || self.class.expire
    @sleep   = options[:sleep]   || self.class.sleep
  end

  def lock
    result = false
    start_at = now
    while now - start_at < @timeout
      break if result = try_lock
      sleep @sleep.to_f
    end

    yield if block_given? && result

    result
  ensure
    unlock if block_given?
  end

  def try_lock
    @zk.create(@key, :data => expiration, :mode => :persistent)
    @token = @zk.stat(@key).czxid

    if @stolen
      @stolen = false
      :recovered
    else
      true
    end
  rescue ZK::Exceptions::NodeExists
    data, _ = @zk.get(@key)
    if data.to_i < now.to_i
      @zk.delete(@key)
      @stolen = true
      retry
    else
      false
    end
  rescue ZK::Exceptions::NoNode
    @zk.mkdir_p(@root)
    retry
  end

  def unlock
    if mine?
      @zk.delete(@key)
      true
    else
      false
    end
  rescue ZK::Exceptions::NoNode
    false
  end

  def extend
    if mine?
      @zk.set(@key, expiration)
      true
    else
      false
    end
  end

  def now
    Time.now
  end

  def delete!
    @zk.delete(@key, :ignore => :no_node)
  end

  private

  def mine?
    @zk.stat(@key).czxid == @token
  end

  def expiration
    (now.to_i + @expire).to_s
  end
end
