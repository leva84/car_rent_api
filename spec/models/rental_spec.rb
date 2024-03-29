describe Rental, type: :model do
  it 'has a valid factory' do
    expect(build(:rental)).to be_valid
    expect(create(:rental)).to be_present
  end

  it { should belong_to(:car) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:car) }
  it { should validate_presence_of(:user) }
end
