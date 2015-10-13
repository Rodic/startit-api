class CreateParticipations < ActiveRecord::Migration
  def up
    sql = %{
      CREATE TABLE participations (
        user_id  bigint not null REFERENCES users  ON DELETE CASCADE,
        event_id bigint not null REFERENCES events ON DELETE CASCADE,

        created_at timestamp with time zone not null default NOW(),
        updated_at timestamp with time zone not null default NOW(),

        PRIMARY KEY(user_id, event_id)
      );
    }
    execute sql
  end

  def down
    sql = %{
      DROP TABLE participations;
    }
    execute sql
  end
end
