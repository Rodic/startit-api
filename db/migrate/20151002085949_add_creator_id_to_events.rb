class AddCreatorIdToEvents < ActiveRecord::Migration
  def up
    # creator_id can be null. Don't want to lose event if creator decide to delete her account!
    sql = %q{
      ALTER TABLE events ADD creator_id bigint default null REFERENCES users ON DELETE SET NULL;
    }
    execute sql
  end

  def down
    sql = %q{
      ALTER TABLE events DROP COLUMN creator_id;
    }
    execute sql
  end
end
