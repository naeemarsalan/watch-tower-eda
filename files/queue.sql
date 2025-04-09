-- 1. Create schema if not exists
CREATE SCHEMA IF NOT EXISTS queue;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create table if not exists
CREATE TABLE IF NOT EXISTS queue.message (
    id UUID NOT NULL DEFAULT uuid_generate_v4(),
    channel TEXT,
    data JSON,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (id)
);

-- 3. Create function for notification
CREATE OR REPLACE FUNCTION queue.new_message_notify()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    PERFORM pg_notify(cast(NEW.channel as text), row_to_json(NEW)::text);
    RETURN NEW;
END;
$function$;

-- 4. Create trigger if it does not exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'new_insert_trigger'
    ) THEN
        CREATE TRIGGER new_insert_trigger
        AFTER INSERT ON queue.message
        FOR EACH ROW
        EXECUTE FUNCTION queue.new_message_notify();
    END IF;
END;
$$;