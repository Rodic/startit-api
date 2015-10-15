class CreateTriggerToInsertEventCreatorIntoParticipants < ActiveRecord::Migration
  def up
    sql = %{
      CREATE OR REPLACE FUNCTION creator_to_participants() RETURNS TRIGGER AS $F$
      BEGIN
        IF new.creator_id IS NOT NULL THEN
          INSERT INTO participations(user_id, event_id) VALUES(new.creator_id, new.id);
          RETURN new;
        ELSE
          RETURN NULL;
        END IF;
      END
      $F$ language plpgsql;

      CREATE TRIGGER creator_to_participants_trig
        AFTER INSERT ON events
        FOR EACH ROW
        EXECUTE PROCEDURE creator_to_participants();
    }
    execute sql
  end

  def down
    sql = %{
      DROP TRIGGER creator_to_participants_trig ON events;
      DROP FUNCTION creator_to_participants();
    }
    execute sql
  end
end
