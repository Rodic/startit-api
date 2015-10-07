class CreateUsers < ActiveRecord::Migration
  def up
    # Although 'provider' and 'uid' are perfectly fine composite key,
    # don't want to expose them in API calls or results and violate users privacy
    sql = %{
      CREATE TABLE users (
        id bigserial not null primary key,

        provider varchar(25) not null CHECK(provider IN ('facebook', 'google')),
        uid varchar(256) not null,

        username varchar(100) not null,
        email varchar(150) default null,

        latitude  numeric(9, 7)  default null CHECK(latitude  >= -90  AND latitude  <= 90),
        longitude numeric(10, 7) default null CHECK(longitude >= -180 AND longitude <= 180),

        created_at timestamp with time zone not null default NOW(),
        updated_at timestamp with time zone not null default NOW()
      );
      CREATE UNIQUE INDEX provider_uid_unique ON users (provider, uid);
    }
    execute sql
  end

  def down
    sql = %{
      DROP TABLE users;
    }
    execute sql
  end
end
