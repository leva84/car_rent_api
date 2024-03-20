describe User, type: :model do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
    expect(create(:user)).to be_present
  end

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(User::MIN_NAME_LENGTH).is_at_most(User::MAX_NAME_LENGTH) }
  it { should have_one(:rental) }
  it { should have_one(:car).through(:rental) }
end
