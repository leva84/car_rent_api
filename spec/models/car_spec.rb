describe Car, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(2).is_at_most(150) }
  it { should define_enum_for(:status).with_values(available: 0, rented: 1, maintenance: 2) }
  it { should have_one(:rental) }
  it { should have_one(:user).through(:rental) }
end
