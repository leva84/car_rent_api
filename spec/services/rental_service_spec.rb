describe RentalService, type: :service do
  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:service) { described_class.new(car: car, user: user) }
  let(:statuses) { Car.statuses.invert }
  let(:available) { Car::AVAILABLE }
  let(:rented) { Car::RENTED }

  describe '#start_rental' do
    it 'creates rental' do
      expect { service.start_rental }.to change { Rental.count }.by(1)
    end

    it 'changes car status to rented' do
      expect { service.start_rental }.to change { car.reload.status }.from(statuses[available]).to(statuses[rented])
    end
  end

  describe '#end_rental' do
    before { service.start_rental }

    it 'changes car status to available' do
      service.start_rental
      expect { service.end_rental }.to change { car.reload.status }.from(statuses[rented]).to(statuses[available])
    end

    it 'deletes rental' do
      expect { service.end_rental }.to change { Rental.count }.by(-1)
    end
  end
end
