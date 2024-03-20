describe RentalService, type: :service do
  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:service) { described_class.new(car: car, user: user) }

  describe '#start_rental' do
    it 'changes car status to rented' do
      expect { service.start_rental }.to change { car.reload.status }.from('available').to('rented')
    end
  end

  describe '#end_rental' do
    it 'changes car status to available' do
      service.start_rental
      expect { service.end_rental }.to change { car.reload.status }.from('rented').to('available')
    end
  end
end
