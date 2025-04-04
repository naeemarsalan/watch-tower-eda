CREATE TABLE queue.message (
    id UUID NOT NULL DEFAULT uuid_generate_v4(),
    channel TEXT,
    data JSON,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (id)
);
CREATE OR REPLACE FUNCTION queue.new_message_notify()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
            DECLARE
            BEGIN
                PERFORM pg_notify(cast(NEW.channel as text), row_to_json(new)::text);
                RETURN NEW;
            END;
            $function$