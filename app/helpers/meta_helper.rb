module MetaHelper
  extend self

  def hash_eval(hash, eval_str)
    inner = Inner.new hash
    inner.instance_eval eval_str
  end

  private

  class Inner
    def initialize(hash)
      @hash = hash
    end

    def method_missing(m, *arg, &block)
      return @hash[m] if @hash.include? m
      super
    end
  end
end
