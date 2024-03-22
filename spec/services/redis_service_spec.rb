describe RedisService do
  describe '.client' do
    it 'returns a Redis client' do
      expect(described_class.client).to be_a(Redis)
    end

    it 'returns the same Redis client object on subsequent calls' do
      expect(described_class.client).to eq(described_class.client)
    end
  end
end
