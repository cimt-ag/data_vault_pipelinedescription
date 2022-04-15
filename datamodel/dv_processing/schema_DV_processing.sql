

-- DROP SCHEMA DV_PIPELINE_DESCRIPTION;

CREATE schema if not EXISTS DV_PROCESSING;

COMMENT ON SCHEMA DV_PROCESSING
  IS 'Functions and support views for processing data vault loads';