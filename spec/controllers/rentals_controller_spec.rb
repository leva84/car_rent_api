describe RentalsController, type: :controller do
  let(:user) { create(:user) }
  let(:car) { create(:car) }

  describe 'POST #start_rental' do
    subject { post :start_rental, params: { user_id: user.id, car_id: car.id } }

    it 'returns http status ok' do
      expect(subject).to have_http_status(:ok)
    end

    it 'calls RentalService#start_rental' do
      expect_any_instance_of(RentalService).to receive(:start_rental)
      subject
    end
  end

  describe 'DELETE #end_rental' do
    subject { delete :end_rental, params: { user_id: user.id, car_id: car.id } }

    it 'returns http status ok' do
      expect(subject).to have_http_status(:ok)
    end

    it 'calls RentalService#end_rental' do
      expect_any_instance_of(RentalService).to receive(:end_rental)
      subject
    end
  end
end
