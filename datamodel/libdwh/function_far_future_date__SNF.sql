
--drop function libdwh.far_future_date();

CREATE OR REPLACE FUNCTION libdwh.far_future_date()
RETURNS TIMESTAMP
NOT NULL
MEMOIZABLE
COMMENT = 'Provides the date constant, that is used as load enddate in the currently valid rows'
AS
$$
    '2999-12-30 00:00:00.000'::TIMESTAMP
$$
;