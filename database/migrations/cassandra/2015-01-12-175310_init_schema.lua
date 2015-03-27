local Migration = {
  name = "2015-01-12-175310_init_schema",

  init = true,

  up = function(options)
    return [[
      CREATE KEYSPACE IF NOT EXISTS "]]..options.keyspace..[["
        WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 1};

      USE ]]..options.keyspace..[[;

      CREATE TABLE IF NOT EXISTS schema_migrations(
        id text PRIMARY KEY,
        migrations list<text>
      );

      CREATE TABLE IF NOT EXISTS consumers(
        id uuid,
        custom_id text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON consumers(custom_id);

      CREATE TABLE IF NOT EXISTS applications(
        id uuid,
        consumer_id uuid,
        public_key text, -- This is the public
        secret_key text, -- This is the secret key, it could be an apikey or basic password
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON applications(consumer_id);
      CREATE INDEX IF NOT EXISTS ON applications(public_key);

      CREATE TABLE IF NOT EXISTS apis(
        id uuid,
        name text,
        public_dns text,
        target_url text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON apis(name);
      CREATE INDEX IF NOT EXISTS ON apis(public_dns);

      CREATE TABLE IF NOT EXISTS plugins_configurations(
        id uuid,
        api_id uuid,
        application_id uuid,
        name text,
        value text, -- serialized plugin data
        enabled boolean,
        created_at timestamp,
        PRIMARY KEY (id, name)
      );

      CREATE INDEX IF NOT EXISTS ON plugins_configurations(name);
      CREATE INDEX IF NOT EXISTS ON plugins_configurations(api_id);
      CREATE INDEX IF NOT EXISTS ON plugins_configurations(application_id);

      CREATE TABLE IF NOT EXISTS metrics(
        api_id uuid,
        identifier text,
        period text,
        period_date timestamp,
        value counter,
        PRIMARY KEY ((api_id, identifier, period_date, period))
      );
    ]]
  end,

  down = function(options)
    return [[
      DROP KEYSPACE ]]..options.keyspace..[[;
    ]]
  end
}

return Migration
