describe Rental, type: :model do
  it 'has a valid factory' do
    expect(build(:rental)).to be_valid
    expect(create(:rental)).to be_present
  end

  it { should belong_to(:car) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:car) }
  it { should validate_presence_of(:user) }

  describe '#set_car_to_rented' do
    let(:car) { create(:car) }
    let(:user) { create(:user) }
    let(:rental) { build(:rental, car:, user:) }

    it 'sets the car to rented' do
      expect { rental.save! }.to change { car.reload.status }.from('available').to('rented')
    end
  end
end
