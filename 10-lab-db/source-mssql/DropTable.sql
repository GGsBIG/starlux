USE TestDB;
  GO

EXEC sys.sp_cdc_disable_table
  @source_schema = N'dbo',
  @source_name   = N'mi_source',
  @capture_instance  = N'dbo_mi_source';
  GO

drop table [dbo].[mi_source];
