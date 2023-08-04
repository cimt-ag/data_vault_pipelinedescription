-- =====================================================================
-- 
-- Copyright 2023 Erwin Brandstetter who provided the code 
-- public domain on stack overflow
--
-- =====================================================================

--drop function f_is_json(_txt text);
create or replace  function dv_pipeline_description.f_is_json(_txt text)
  RETURNS bool
  LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE AS
$$
BEGIN
   RETURN _txt::json IS NOT NULL;
EXCEPTION
   WHEN SQLSTATE '22P02' THEN  -- invalid_text_representation
      RETURN false;
END
$$;

COMMENT ON FUNCTION dv_pipeline_description.f_is_json(text) IS 'Test if input text is valid JSON.Returns true, false, or NULL on NULL input.';