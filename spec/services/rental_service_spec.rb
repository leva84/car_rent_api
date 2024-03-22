describe RentalService, type: :service do
  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:service) { described_class.new(car: car, user: user) }
  let(:statuses) { Car.statuses.invert }
  let(:available) { Car::AVAILABLE }
  let(:rented) { Car::RENTED }

  shared_examples :re_execution_without_cache do
    it 'does not change car status' do
      expect { subject }.not_to(change { car.reload.status })
    end

    it 'does not change rental count' do
      expect { subject }.not_to change(Rental, :count)
    end

    it 'does not write rental data to Redis' do
      expect(service).not_to receive(:write_rental_data_to_redis)
      subject
    end
  end

  shared_examples :re_execution_with_cache do |operation_key|
    it 'does not change car status' do
      expect { subject }.not_to(change { car.reload.status })
    end

    it 'does not change rental count' do
      expect { subject }.not_to change(Rental, :count)
    end

    it 'does not write rental data to Redis' do
      expect(service).not_to receive(:write_rental_data_to_redis).with(operation_key)
      subject
    end
  end

  describe '#start_rental' do
    context 'when car and user are valid' do
      it 'creates rental' do
        expect { service.start_rental }.to change { Rental.count }.by(1)
      end

      it 'changes car status to rented' do
        expect { service.start_rental }.to change { car.reload.status }.from(statuses[available]).to(statuses[rented])
      end

      it 'writes rental data to Redis' do
        expect(service).to receive(:write_rental_data_to_redis).with(RentalService::START_RENTAL_KEY)
        service.start_rental
      end
    end

    context 'when user has open rentals' do
      subject { service.start_rental }

      before { create(:rental, user: user) }

      include_examples :re_execution_without_cache do
        it 'adds error to the service' do
          subject
          expect(service.errors.full_messages).to include('User there are open rentals')
        end
      end
    end

    context 'when rental already started' do
      subject { service.start_rental }

      before { service.start_rental }

      include_examples :re_execution_with_cache, RentalService::START_RENTAL_KEY
    end
  end

  describe '#end_rental' do
    context 'when rental exists' do
      before { service.start_rental }

      it 'changes car status to available' do
        expect { service.end_rental }.to change { car.reload.status }.from(statuses[rented]).to(statuses[available])
      end

      it 'deletes rental' do
        expect { service.end_rental }.to change { Rental.count }.by(-1)
      end

      it 'writes rental data to Redis' do
        expect(service).to receive(:write_rental_data_to_redis).with(RentalService::END_RENTAL_KEY)
        service.end_rental
      end
    end

    context 'when rental does not exist' do
      subject { service.end_rental }

      include_examples :re_execution_without_cache do
        it 'adds error to the service' do
          subject
          expect(service.errors.full_messages).to include('Rental not exists')
        end
      end
    end

    context 'when rental already ended' do
      subject { service.end_rental }

      before { service.end_rental }

      include_examples :re_execution_with_cache, RentalService::END_RENTAL_KEY
    end
  end
end
