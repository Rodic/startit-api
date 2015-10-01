require 'rails_helper'

RSpec.describe User, type: :model do

  describe "database level validations" do

    it "validates with proper data" do
      expect{ FactoryGirl.create(:user) }.not_to raise_exception
    end

    describe "id" do

      it "is autoincrementd" do
        u1 = FactoryGirl.create(:user)
        u2 = FactoryGirl.create(:user)
        expect(u2.id - u1.id).to eq(1)
      end

      it "cannot be null" do
        u = FactoryGirl.create(:user, id: nil)
        expect(u.id).not_to be_nil
        expect(u.id).to be_integer
      end
    end

    describe "provider" do

      it "fails when null" do
        u = FactoryGirl.build(:user, provider: nil)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when not 'facebook'" do
        [ 'facebook' ].each do |p|
          u = FactoryGirl.build(:user, provider: p)
          expect{ u.save(validate: false) }.not_to raise_exception
        end

        [ 'unknown', 'test' ].each do |p|
          u = FactoryGirl.build(:user, provider: p)
          expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)
        end
      end
    end

    describe "uid" do
      it "fails when null" do
        u = FactoryGirl.build(:user, uid: nil)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end
    end

    describe "provider and uid uniqueness" do
      it "fails when not unique" do
        u1 = FactoryGirl.create(:user, provider: 'facebook', uid: 12345)
        u2 = FactoryGirl.build(:user, provider: 'facebook', uid: 12345)

        expect{ u2.save(validate: false) }.to raise_exception(ActiveRecord::RecordNotUnique, /PG::UniqueViolation/)
      end
    end

    describe "latitude" do

      it "is optional" do
        u = FactoryGirl.build(:user, latitude: nil)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "fails when is less than -90" do
        u = FactoryGirl.build(:user, latitude: -90.0000001)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        u = FactoryGirl.build(:user, latitude: -90.0000000)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "fails when is greater than 90" do
        u = FactoryGirl.build(:user, latitude: 90.0000001)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        u = FactoryGirl.build(:user, latitude: 90.0000000)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "has precision of (2,7)" do
        u = FactoryGirl.create(:user, latitude: 12.12345678)
        expect(u.latitude).to eq(12.1234568)

        u = FactoryGirl.build(:user, latitude: 123.1234567)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NumericValueOutOfRange/)
      end
    end

    describe "longitude" do

      it "is optional" do
        u = FactoryGirl.build(:user, longitude: nil)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "fails when is less than -90" do
        u = FactoryGirl.build(:user, longitude: -180.0000001)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        u = FactoryGirl.build(:user, longitude: -180.0000000)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "fails when is greater than 90" do
        u = FactoryGirl.build(:user, longitude: 180.0000001)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        u = FactoryGirl.build(:user, longitude: 180.0000000)
        expect{ u.save(validate: false) }.not_to raise_exception
      end

      it "has precision of (3,7)" do
        u = FactoryGirl.create(:user, longitude: 123.12345678)
        expect(u.longitude).to eq(123.1234568)

        u = FactoryGirl.build(:user, longitude: 1234.1234567)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NumericValueOutOfRange/)
      end
    end

    describe "username" do
      it "fails when null" do
        u = FactoryGirl.build(:user, username: nil)
        expect{ u.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end
    end

    describe "created_at" do
      it "is created automatically" do
        u = FactoryGirl.create(:user)
        expect(u.created_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "updated_at" do
      it "is created automatically" do
        u = FactoryGirl.create(:user)
        expect(u.updated_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end
  end


  describe "application level validations" do

    it "passes with proper data" do
      expect(FactoryGirl.build(:user)).to be_valid
    end

    describe "provider" do

      it "fails when nil" do
        [ nil, "" ].each do |p|
          u = FactoryGirl.build(:user, provider: p)
          expect(u).not_to be_valid
          expect(u.errors[:provider]).to include("can't be blank")
        end
      end

      it "fails when not 'facebook'" do
        [ 'facebook' ].each do |p|
          u = FactoryGirl.build(:user, provider: p)
          expect(u).to be_valid
        end

        [ 'unknown', 'test' ].each do |p|
          u = FactoryGirl.build(:user, provider: p)
          expect(u).not_to be_valid
          expect(u.errors[:provider]).to include("must be on of the following: 'facebook'")
        end
      end
    end

    describe "uid" do
      it "fails when nil" do
        [ nil, '' ].each do |uid|
          u = FactoryGirl.build(:user, uid: uid)
          expect(u).not_to be_valid
          expect(u.errors[:uid]).to include("can't be blank")
        end
      end
    end

    describe "latitude" do

      it "is optional" do
        [ nil, '' ].each do |l|
          u = FactoryGirl.build(:user, latitude: l)
          expect(u).to be_valid
        end
      end

      it "fails when not a number" do
        u = FactoryGirl.build(:user, latitude: 'high')
        expect(u).not_to be_valid
        expect(u.errors[:latitude]).to include("is not a number")
      end

      it "fails when is smaller than -90" do
        u = FactoryGirl.build(:user, latitude: -90.0001)
        expect(u).not_to be_valid
        expect(u.errors[:latitude]).to include("must be greater than or equal to -90")
      end

      it "fails when is bigger than 90" do
        u = FactoryGirl.build(:user, latitude: 90.0001)
        expect(u).not_to be_valid
        expect(u.errors[:latitude]).to include("must be less than or equal to 90")
      end
    end

    describe "longitude" do

      it "is optional" do
        [ nil, '' ].each do |l|
          u = FactoryGirl.build(:user, longitude: l)
          expect(u).to be_valid
        end
      end

      it "fails when not a number" do
        u = FactoryGirl.build(:user, longitude: 'low')
        expect(u).not_to be_valid
        expect(u.errors[:longitude]).to include("is not a number")
      end

      it "fails when is smaller than -180" do
        u = FactoryGirl.build(:user, longitude: -180.0001)
        expect(u).not_to be_valid
        expect(u.errors[:longitude]).to include("must be greater than or equal to -180")
      end

      it "fails when is bigger than 180" do
        u = FactoryGirl.build(:user, longitude: 180.0001)
        expect(u).not_to be_valid
        expect(u.errors[:longitude]).to include("must be less than or equal to 180")
      end
    end

    describe "username" do
      it "fails when nil" do
        [ nil, '' ].each do |uname|
          u = FactoryGirl.build(:user, username: uname)
          expect(u).not_to be_valid
          expect(u.errors[:username]).to include("can't be blank")
        end
      end
    end

    describe "email" do

      it "is optional" do
        [nil, ''].each do |e|
          u = FactoryGirl.build(:user, email: e)
          expect(u).to be_valid
        end
      end

      it "fails when in not proper form" do

        valids = [
          "valid@email.com",
          "valid@with-hypen.org",
          "first.last@name.com"
        ]

        valids.each do |valid|
          u = FactoryGirl.build(:user, email: valid)
          expect(u).to be_valid
        end

        invalids = [
          "invalid",
          "invalid@with-at",
          "invalid@with@multiple-at"
        ]

        invalids.each do |invalid|
          u = FactoryGirl.build(:user, email: invalid)
          expect(u).not_to be_valid
          expect(u.errors[:email]).to include("invalid format")
        end
      end
    end

    describe "updated_at" do
      it "is auto updated when record is edited" do
        u = FactoryGirl.create(:user)
        up = u.updated_at

        u.username = "Jane Doe"
        u.save

        expect(up).not_to eq(u.updated_at)
      end
    end
  end
end
