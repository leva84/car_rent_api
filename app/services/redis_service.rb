class RedisService
  class << self
    def client
      @client ||= new_client
    end

    private

    def new_client
      Redis.new(url: 'redis://redis:6379')
    end
  end
end
