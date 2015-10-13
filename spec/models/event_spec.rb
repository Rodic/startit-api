require 'rails_helper'

RSpec.describe Event, type: :model do

  describe "database level validations" do

    it "validates with proper data" do
      expect{ FactoryGirl.create(:event) }.not_to raise_exception
    end

    describe "id" do

      it "is autoincrementd" do
        e1 = FactoryGirl.create(:event)
        e2 = FactoryGirl.create(:event)
        expect(e2.id - e1.id).to eq(1)
      end

      it "cannot be null" do
        e = FactoryGirl.create(:event, id: nil)
        expect(e.id).not_to be_nil
        expect(e.id).to be_integer
      end
    end

    describe "start_latitude" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, start_latitude: nil)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when is less than -90" do
        e = FactoryGirl.build(:event, start_latitude: -90.0000001)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        e = FactoryGirl.build(:event, start_latitude: -90.0000000)
        expect{ e.save(validate: false) }.not_to raise_exception
      end

      it "fails when is greater than 90" do
        e = FactoryGirl.build(:event, start_latitude: 90.0000001)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        e = FactoryGirl.build(:event, start_latitude: 90.0000000)
        expect{ e.save(validate: false) }.not_to raise_exception
      end

      it "has precision of (2,7)" do
        e = FactoryGirl.create(:event, start_latitude: 12.12345678)
        expect(e.start_latitude).to eq(12.1234568)

        e = FactoryGirl.build(:event, start_latitude: 123.1234567)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NumericValueOutOfRange/)
      end
    end

    describe "start_longitude" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, start_longitude: nil)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when is less than -90" do
        e = FactoryGirl.build(:event, start_longitude: -180.0000001)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        e = FactoryGirl.build(:event, start_longitude: -180.0000000)
        expect{ e.save(validate: false) }.not_to raise_exception
      end

      it "fails when is greater than 90" do
        e = FactoryGirl.build(:event, start_longitude: 180.0000001)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)

        e = FactoryGirl.build(:event, start_longitude: 180.0000000)
        expect{ e.save(validate: false) }.not_to raise_exception
      end

      it "has precision of (3,7)" do
        e = FactoryGirl.create(:event, start_longitude: 123.12345678)
        expect(e.start_longitude).to eq(123.1234568)

        e = FactoryGirl.build(:event, start_longitude: 1234.1234567)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NumericValueOutOfRange/)
      end
    end

    describe "start_time" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, start_time: nil)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "is stored in utc" do
        e = FactoryGirl.build(:event, start_time: '2184-01-19 05:23:54+02')
        expect(e.start_time).to eq('2184-01-19 03:23:54')
      end

      it "fails when is in the past" do
        e = FactoryGirl.build(:event, start_time: 1.day.ago)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)
      end
    end

    describe "description" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, description: nil)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when is longer than 500 chars" do
        e = FactoryGirl.build(:event, description: 'a' * 501)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::StringDataRightTruncation/)
      end

      it "passes when is 500 chars long" do
        e = FactoryGirl.build(:event, description: 'a' * 500)
        expect{ e.save(validate: false) }.not_to raise_exception
      end
    end

    describe "title" do

      it "can have a title" do
        e = FactoryGirl.create(:event, title: "My running event")
        expect(e.title).to eq("My running event")

        e = FactoryGirl.create(:event, title: nil)
        expect(e.title).to be_nil
      end

      it "fails when is longer than 150 chars" do
        e = FactoryGirl.build(:event, title: 'a'*151)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::StringDataRightTruncation/)
      end

      it "passes when is 150 chars long" do
        e = FactoryGirl.build(:event, title: 'a'*150)
        expect{ e.save(validate: false) }.not_to raise_exception
      end
    end

    describe "type" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, type: nil)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when type is not 'Run' or 'BikeRide'" do
        [ 'Run', 'BikeRide' ].each do |t|
          e = FactoryGirl.build(:event, type: t)
          expect{ e.save(validate: false) }.not_to raise_exception
        end

        [ 'Unknown', 'Dinner', 'Karate' ].each do |t|
          e = FactoryGirl.build(:event, type: t)
          expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::StatementInvalid, /PG::CheckViolation/)
        end
      end
    end

    describe "creator_id" do

      it "can be null" do
        e = FactoryGirl.build(:event, creator: nil)
        expect{ e.save(validate: false) }.not_to raise_exception
      end

      it "cannot reference user that doesn't exist" do
        e = FactoryGirl.build(:event, creator_id: 0)
        expect{ e.save(validate: false) }.to raise_exception(ActiveRecord::InvalidForeignKey, /events_creator_id_fkey/)
      end

      it "is null when creator is deleted" do
        u = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event, creator: u)

        expect(e.creator_id).to eq(u.id)

        u.destroy
        e.reload

        expect(e.creator_id).to be_nil
      end
    end

    describe "created_at" do

      it "is created automatically" do
        e = FactoryGirl.create(:event)
        expect(e.created_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "updated_at" do

      it "is created automatically" do
        e = FactoryGirl.create(:event)
        expect(e.updated_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end
  end

  describe "application level validations" do

    it "passes with proper data" do
      expect(FactoryGirl.build(:event)).to be_valid
    end

    describe "start_latitude" do

      it "fails when is nil" do
        [ nil, '' ].each do |l|
          e = FactoryGirl.build(:event, start_latitude: l)
          expect(e).not_to be_valid
          expect(e.errors[:start_latitude]).to include("can't be blank")
        end
      end

      it "fails when not a number" do
        e = FactoryGirl.build(:event, start_latitude: 'high')
        expect(e).not_to be_valid
        expect(e.errors[:start_latitude]).to include("is not a number")
      end

      it "fails when is smaller than -90" do
        e = FactoryGirl.build(:event, start_latitude: -90.0001)
        expect(e).not_to be_valid
        expect(e.errors[:start_latitude]).to include("must be greater than or equal to -90")
      end

      it "fails when is bigger than 90" do
        e = FactoryGirl.build(:event, start_latitude: 90.0001)
        expect(e).not_to be_valid
        expect(e.errors[:start_latitude]).to include("must be less than or equal to 90")
      end
    end

    describe "start_longitude" do
      it "fails when is nil" do
        [ nil, '' ].each do |l|
          e = FactoryGirl.build(:event, start_longitude: l)
          expect(e).not_to be_valid
          expect(e.errors[:start_longitude]).to include("can't be blank")
        end
      end

      it "fails when not a number" do
        e = FactoryGirl.build(:event, start_longitude: 'low')
        expect(e).not_to be_valid
        expect(e.errors[:start_longitude]).to include("is not a number")
      end

      it "fails when is smaller than -180" do
        e = FactoryGirl.build(:event, start_longitude: -180.0001)
        expect(e).not_to be_valid
        expect(e.errors[:start_longitude]).to include("must be greater than or equal to -180")
      end

      it "fails when is bigger than 180" do
        e = FactoryGirl.build(:event, start_longitude: 180.0001)
        expect(e).not_to be_valid
        expect(e.errors[:start_longitude]).to include("must be less than or equal to 180")
      end
    end

    describe "start_time" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, start_time: nil)
        expect(e).not_to be_valid
        expect(e.errors[:start_time]).to include("can't be blank")
      end

      it "fails when is in the past" do
        e = FactoryGirl.build(:event, start_time: 1.day.ago)
        expect(e).not_to be_valid
        expect(e.errors[:start_time]).to include("can't be in the past")
      end
    end

    describe "description" do

      it "fails when is null" do
        e = FactoryGirl.build(:event, description: nil)
        expect(e).not_to be_valid
        expect(e.errors[:description]).to include("can't be blank")
      end

      it "fails when is longer than 500 chars" do
        e = FactoryGirl.build(:event, description: 'a' * 501)
        expect(e).not_to be_valid
        expect(e.errors[:description]).to include("is too long (maximum is 500 characters)")
      end

      it "passes when is 500 chars long" do
        e = FactoryGirl.build(:event, description: 'a' * 500)
        expect(e).to be_valid
      end
    end

    describe "title" do

      it "can have a title" do
        e = FactoryGirl.create(:event, title: "My running event")
        expect(e.title).to eq("My running event")

        e = FactoryGirl.create(:event, title: nil)
        expect(e.title).to be_nil
      end

      it "fails when is longer than 150 chars" do
        e = FactoryGirl.build(:event, title: 'a'*151)
        expect(e).not_to be_valid
        expect(e.errors[:title]).to include("is too long (maximum is 150 characters)")
      end

      it "passes when is 150 chars long" do
        e = FactoryGirl.build(:event, title: 'a'*150)
        expect(e).to be_valid
      end
    end

    describe "type" do

      it "fails when nil" do
        e = FactoryGirl.build(:event, type: nil)
        expect(e).not_to be_valid
        expect(e.errors[:type]).to include("can't be blank")
      end

      it "fails when not 'Run' or 'BikeRide'" do
        [ 'Run', 'BikeRide' ].each do |t|
          e = FactoryGirl.build(:event, type: t)
          expect(e).to be_valid
        end

        [ 'Unknown', 'Dinner', 'Karate' ].each do |t|
          e = FactoryGirl.build(:event, type: t)
          expect(e).not_to be_valid
          expect(e.errors[:type]).to include("must be 'Run' or 'BikeRide'")
        end
      end
    end

    describe "creator_id" do
      it "can be null" do
        [ nil, '' ].each do |c|
          e = FactoryGirl.build(:event, creator_id: c)
          expect(e).to be_valid
        end
      end
    end

    describe "updated_at" do

      it "is auto updated when record is edited" do
        e = FactoryGirl.create(:event)
        u = e.updated_at

        e.title = "New title"
        e.save

        expect(u).not_to eq(e.updated_at)
      end
    end
  end

  describe "associations" do

    it "belongs to user (as creator)" do
      u = FactoryGirl.create(:user)
      e = FactoryGirl.create(:event, creator: u)

      expect(e.creator).to eq(u)
    end

    it "has many participations" do
      e = FactoryGirl.create(:event)
      p1 = FactoryGirl.build(:participation)
      p2 = FactoryGirl.build(:participation)

      e.participations << p1
      e.participations << p2

      expect(e.participations).to match_array([ p1, p2 ])
    end

    it "has many participants" do
      e = FactoryGirl.create(:run)
      u1 = FactoryGirl.create(:user)
      u2 = FactoryGirl.create(:user)

      e.participants << u1
      e.participants << u2

      expect(e.participants).to match_array([u1, u2])
    end
  end

  describe "scopes" do

    describe "upcoming" do

      let!(:asap) { (Time.now + 0.1.second).strftime("%Y %h %d %H:%M:%S.%L") }

      it "lists upcoming events" do
        e1 = FactoryGirl.create(:run, start_time: asap)
        e2 = FactoryGirl.create(:run, start_time: 2.days.from_now)
        e3 = FactoryGirl.create(:bike_ride, start_time: 1.week.from_now)
        e4 = FactoryGirl.create(:bike_ride, start_time: asap)

        sleep(0.2)

        expect(Event.upcoming).to contain_exactly(e2, e3)
      end
    end
  end

  describe "callbacks" do

    describe "save_start_time_utc" do
      it "writes start_time in utc" do
        e = Run.new(FactoryGirl.attributes_for(:run))
        expect(e.start_time_utc).to be_nil
        e.save
        expect(e.save_start_time_utc).not_to be_nil
      end
    end
  end
end
