require 'rails_helper'

RSpec.describe Participation, type: :model do
  describe "db level validations" do

    it "passes with proper data" do
      p = FactoryGirl.build(:participation)
      expect{ p.save(validate: false) }.not_to raise_error
    end

    describe "user_id" do
      it "fails when null" do
        p = FactoryGirl.build(:participation, user_id: nil)
        expect{ p.save(validate: false) }.to raise_error(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when references non existing user" do
        p = FactoryGirl.build(:participation, user_id: 0)
        expect{ p.save(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey, /PG::ForeignKeyViolation/)
      end

      it "record gets deleted when user is destroyed" do
        u = FactoryGirl.create(:user)
        # event creator is inserted in participations
        expect{ FactoryGirl.create(:event, creator: u) }.to change{ Participation.count }.from(0).to(1)
        expect{ u.destroy }.to change{ Participation.count }.from(1).to(0)
      end
    end

    describe "event_id" do
      it "fails when null" do
        p = FactoryGirl.build(:participation, event_id: nil)
        expect{ p.save(validate: false) }.to raise_error(ActiveRecord::StatementInvalid, /PG::NotNullViolation/)
      end

      it "fails when references non existing event" do
        p = FactoryGirl.build(:participation, event_id: 0)
        expect{ p.save(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey, /PG::ForeignKeyViolation/)
      end

      it "record gets deleted when event is destroyed" do
        # event creator is inserted in participations
        expect{ FactoryGirl.create(:event) }.to change{ Participation.count }.from(0).to(1)
        expect{ Event.last.destroy }.to change{ Participation.count }.from(1).to(0)
      end
    end

    describe "created_at" do
      it "is created automatically" do
        p = FactoryGirl.create(:participation)
        expect(p.created_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "updated_at" do
      it "is created automatically" do
        p = FactoryGirl.create(:participation)
        expect(p.updated_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "primary key" do
      it "raises an error when combination of user_id and event_id is not unique" do
        u = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event)

        expect{ FactoryGirl.create(:participation, user: u, event: e) }.not_to raise_error

        p = FactoryGirl.build(:participation, user: u, event: e)

        expect{ p.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique, /PG::UniqueViolation/)
      end
    end
  end

  describe "application level validations" do
    it "passes with proper data" do
      expect(FactoryGirl.build(:participation)).to be_valid
    end

    describe "user_id" do
      it "fails when nil" do
        [ nil, "" ].each do |u|
          p = FactoryGirl.build(:participation, user_id: u)
          expect(p).not_to be_valid
          expect(p.errors[:user_id]).to include("can't be blank")
        end
      end
    end

    describe "event_id" do
      it "fails when nil" do
        [ nil, "" ].each do |e|
          p = FactoryGirl.build(:participation, event_id: e)
          expect(p).not_to be_valid
          expect(p.errors[:event_id]).to include("can't be blank")
        end
      end
    end

    describe "updated_at" do
      it "is auto updated when record is edited" do
        p = FactoryGirl.build(:participation)
        up = p.updated_at

        e = FactoryGirl.create(:event)

        p.event = e
        p.save

        expect(up).not_to eq(p.updated_at)
      end
    end

    describe "primary key" do
      it "is composed of user_id and event_id" do
        expect(Participation.primary_key).to eq([ "user_id", "event_id" ])
      end

      it "is unique" do
        u = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event)
        expect{ FactoryGirl.create(:participation, user: u, event: e) }.to change{ Participation.count }.by(1)

        p = FactoryGirl.build(:participation, user: u, event: e)
        expect(p).not_to be_valid
        expect(p.errors[:user_id]).to include("has already been registered as a participant")
      end

      it "record can be found by it" do
        u = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event)
        p = FactoryGirl.create(:participation, user: u, event: e)

        expect(Participation.find([u.id, e.id])).to eq(p)
      end
    end
  end

  describe "associations" do
    it "belongs to user" do
      u = FactoryGirl.create(:user)
      p = FactoryGirl.create(:participation, user: u)
      expect(p.user).to eq(u)
    end

    it "belongs to event" do
      e = FactoryGirl.create(:event)
      p = FactoryGirl.create(:participation, event: e)
      expect(p.event).to eq(e)
    end
  end
end
