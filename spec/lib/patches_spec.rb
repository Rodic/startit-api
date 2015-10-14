require 'rails_helper'

describe "ActiveRecord" do
  describe "Validations" do

    describe "save" do

      it "doesn't add message when record is valid" do
        u = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event)
        p = FactoryGirl.build(:participation, user: u, event: e)

        p.save

        expect(p.errors.count).to be(0)
      end

      it "adds message when foreign key references non existing record" do
        e = FactoryGirl.build(:event, creator_id: 0)
        e.save
        expect(e.errors[:creator_id]).to include('is not present in table "users"')

        u = FactoryGirl.create(:user)
        p = Participation.create(user_id: u.id, event_id: 0)
        expect(p.errors[:event_id]).to include('is not present in table "events"')
      end

      it "raises error when validate is 'false'" do
        e = FactoryGirl.build(:event, creator_id: 0)
        expect{ e.save(validate: false) }.to raise_error ActiveRecord::InvalidForeignKey
      end

    end
  end
end
