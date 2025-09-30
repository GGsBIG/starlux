create DATABASE TestDB;
  GO
  USE TestDB;
  GO
  create table [dbo].[mi_source](
  bdl_id char(1),
  bdl_pat_no int,
  bdl_ipd_no char(11),
  bdl_in_dtti char(13),
  bdl_in_dtti_v char(13),
  bdl_chg_bed char(1),
  bdl_group varchar(150)
  );
  GO

  CREATE UNIQUE CLUSTERED INDEX Imi_mbdl0 ON dbo.mi_source(bdl_id, bdl_pat_no, bdl_ipd_no, bdl_in_dtti);
  GO
  CREATE UNIQUE INDEX Imi_mbdl1 ON dbo.mi_source(bdl_id, bdl_in_dtti, bdl_ipd_no);
  GO
  CREATE UNIQUE INDEX Imi_mbdl2 ON dbo.mi_source(bdl_id, bdl_pat_no, bdl_ipd_no, bdl_chg_bed, bdl_in_dtti);
  GO
  CREATE UNIQUE INDEX Imi_mbdl3 ON dbo.mi_source(bdl_id, bdl_pat_no, bdl_ipd_no, bdl_in_dtti_v);
  GO

  EXEC sys.sp_cdc_enable_db;
  GO

  EXEC sys.sp_cdc_enable_table
  @source_schema = N'dbo',
  @source_name   = N'mi_source',
  @role_name     = NULL;
