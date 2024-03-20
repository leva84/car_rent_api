describe RentalsController, type: :controller do
  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:resp) { JSON.parse(response.body) }

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
        expect(resp.fetch('id')).to eq(Rental.last.id)
      end

      include_examples :start_rental_call
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
      let!(:rental) { create(:rental, user: user, car: car) }

      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns rental' do
        subject
        expect(resp.fetch('id')).to eq(rental.id)
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/The rental has already exists/)
        subject
      end

      include_examples :start_rental_call
    end
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
      let!(:rental) { create(:rental, user: user, car: car) }

      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
      end

      it 'returns ok message' do
        subject
        expect(resp.fetch('status')).to eq('ok')
      end

      include_examples :end_rental_call
    end

    context 'without rental' do
      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        subject
        expect(resp.fetch('errors')).to eq(['Rental not exists'])
      end

      include_examples :end_rental_call
    end
  end
end
