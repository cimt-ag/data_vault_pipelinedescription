--DROP function  libdwh.far_future_date;

CREATE OR REPLACE FUNCTION libdwh.far_future_date() RETURNS timestamp AS
$$
begin
    RETURN '2099-01-01 00:00:00'::TIMESTAMP;
EXCEPTION WHEN others THEN
    RETURN NULL;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;


comment on function libdwh.far_future_date() is 'Provides the date constant, that is used as load enddate in the currently valid rows';

--select libdwh.far_future_date();

--/* result should show              1234|             12.34|  [NULL]            | [NULL]        | [NULL]           */
      
