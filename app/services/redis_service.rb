class RedisService
  class << self
    def client
      @client ||= new_client
    end

    private

    def new_client
      Redis.new(url: 'redis://127.0.0.1:6379/0')
    end
  end
end
