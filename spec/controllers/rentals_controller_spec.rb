describe RentalsController, type: :controller do
  let(:user) { create(:user) }
  let(:car) { create(:car) }

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

      include_examples :start_rental_call
    end

    context 'with invalid user' do
      let!(:rental) { create(:rental, user: user) }

      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      include_examples :start_rental_call
    end

    context 'with invalid car' do
      let(:car) { create :car, status: Car::MAINTENANCE }

      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      include_examples :start_rental_call
    end

    context 'with rental' do
      let!(:rental) { create(:rental, user: user, car: car) }

      it 'returns http status ok' do
        expect(subject).to have_http_status(:ok)
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

      include_examples :end_rental_call
    end

    context 'without rental' do
      it 'returns http status unprocessable_entity' do
        expect(subject).to have_http_status(:unprocessable_entity)
      end

      include_examples :end_rental_call
    end
  end
end
