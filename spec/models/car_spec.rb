describe Car, type: :model do
  let(:available) { Car::AVAILABLE }
  let(:rented) { Car::RENTED }
  let(:maintenance) { Car::MAINTENANCE }

  it 'has a valid factory' do
    expect(build(:car)).to be_valid
    expect(create(:car)).to be_present
  end

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(Car::MIN_NAME_LENGTH).is_at_most(Car::MAX_NAME_LENGTH) }
  it { should define_enum_for(:status).with_values(available: available, rented: rented, maintenance: maintenance) }
  it { should have_one(:rental) }
  it { should have_one(:user).through(:rental) }

  describe '#set_car_to_rented' do
    let(:statuses) { described_class.statuses.invert }
    let(:car) { create(:car, status: available) }
    let(:user) { create(:user) }
    let(:rental) { build(:rental, car: car, user: user) }

    it 'sets the car to rented' do
      expect { rental.save! }.to change { car.reload.status }.from(statuses[available]).to(statuses[rented])
    end
  end
end
