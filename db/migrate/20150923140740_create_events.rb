class CreateEvents < ActiveRecord::Migration
  def up
    sql = %{
      CREATE TABLE events (
        id bigserial not null primary key,

        start_latitude  numeric(9, 7)  not null CHECK(start_latitude  >= -90  AND start_latitude  <= 90),
        start_longitude numeric(10, 7) not null CHECK(start_longitude >= -180 AND start_longitude <= 180),

        start_time     timestamp without time zone not null,
        start_time_utc timestamp without time zone not null CHECK(start_time_utc > NOW()),

        description varchar(500) not null,
        title varchar(150) default null,

        type varchar(25) not null CHECK(type IN ('Run', 'BikeRide')),

        created_at timestamp with time zone not null default NOW(),
        updated_at timestamp with time zone not null default NOW()
      );

      create index start_latitude_idx on events(start_latitude);
      create index start_longitude_idx on events(start_longitude);
      create index start_time_idx on events(start_time);
    }
    execute sql
  end

  def down
    sql = %{
      DROP TABLE events;
    }
    execute sql
  end
end
