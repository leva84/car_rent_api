describe Rental, type: :model do
  it { should belong_to(:car) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:car) }
  it { should validate_presence_of(:user) }
end
