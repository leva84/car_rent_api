describe RentalsController, type: :controller do
  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:resp) { JSON.parse(response.body) }

  shared_context :does_not_write_to_redis do
    before do
      allow_any_instance_of(RentalService).to receive(:write_rental_data_to_redis).and_raise(Redis::CommandError)
    end

    it 'does not create rental' do
      expect { subject }.not_to change(Rental, :count)
    end

    it 'returns unprocessable_entity status' do
      expect(subject).to have_http_status(:unprocessable_entity)
    end
  end

  shared_context :raise_active_record do
    before do
      allow(Rental).to receive(:create).and_raise(ActiveRecord::RecordInvalid)
    end

    it 'does not write to Redis' do
      expect_any_instance_of(RentalService).not_to receive(:write_rental_data_to_redis)
      subject
    end

    it 'returns unprocessable_entity status' do
      expect(subject).to have_http_status(:unprocessable_entity)
    end
  end

  shared_examples :writes_to_redis do
    it 'writes to Redis' do
      allow_any_instance_of(RentalService).to receive(:write_rental_data_to_redis)
      expect_any_instance_of(RentalService).to receive(:write_rental_data_to_redis)
      subject
    end
  end

  describe 'POST #start_rental' do
    subject { post :start_rental, params: { user_id: user.id, car_id: car.id } }

    shared_examples :start_rental_call do
      it 'calls RentalService#start_rental' do
        expect_any_instance_of(RentalService).to receive(:start_rental)
        subject
      end
    end

    context 'with valid user and car' do
      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns rental' do
        subject
        expect(resp['rental']['id']).to eq(Rental.last.id)
      end

      include_examples :start_rental_call
      include_examples :writes_to_redis
    end

    context 'with invalid user' do
      let!(:rental) { create(:rental, user: user) }

      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject
        expect(resp.fetch('errors')).to eq(['User there are open rentals'])
      end

      include_examples :start_rental_call
    end

    context 'with invalid car' do
      let(:car) { create :car, status: Car::MAINTENANCE }

      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject
        expect(resp.fetch('errors')).to eq(['Car is not available'])
      end

      include_examples :start_rental_call
    end

    context 'with rental' do
      before do
        RentalService.new(car: car, user: user).start_rental
      end

      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns rental' do
        subject
        expect(resp['rental']['id']).to be_present
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/Rental already exists ID:/)
        subject
      end

      include_examples :start_rental_call
    end

    it_behaves_like :does_not_write_to_redis
    it_behaves_like :raise_active_record
  end

  describe 'DELETE #end_rental' do
    subject { delete :end_rental, params: { user_id: user.id, car_id: car.id } }

    shared_examples :end_rental_call do
      it 'calls RentalService#start_rental' do
        expect_any_instance_of(RentalService).to receive(:end_rental)
        subject
      end
    end

    context 'with rental' do
      before do
        RentalService.new(car: car, user: user).start_rental
      end

      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns ok message' do
        subject
        expect(resp.fetch('status')).to eq('ok')
      end

      include_examples :end_rental_call
      include_examples :writes_to_redis
    end

    context 'without rental' do
      context 'without redis data' do
        it 'returns http status unprocessable_entity' do
          expect(subject).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message' do
          subject
          expect(resp.fetch('errors')).to eq(['Rental not exists'])
        end

        include_examples :end_rental_call
      end

      context 'with redis data' do
        before do
          RentalService.new(car: car, user: user).start_rental
          RentalService.new(car: car, user: user).end_rental
        end

        it 'returns http status unprocessable_entity' do
          expect(subject).to have_http_status(:ok)
        end

        it 'returns ok message' do
          subject
          expect(resp.fetch('status')).to eq('ok')
        end

        it 'logs a warning' do
          expect(Rails.logger).to receive(:warn).with(/Rental already removed ID:/)
          subject
        end

        include_examples :end_rental_call
      end

      it_behaves_like :does_not_write_to_redis
      it_behaves_like :raise_active_record
    end
  end
end
