create DATABASE TestDB;
  GO
  USE TestDB;
  GO
  create table [dbo].[target_id2](
  gravity_pk char(48),
  bdl_id char(1),
  bdl_pat_no int,
  bdl_ipd_no char(11),
  bdl_in_dt char(7),
  bdl_in_ti char(6),
  bdl_in_dt_v char(7),
  bdl_in_ti_v char(6),
  bdl_2_new_cla char(4),
  bdl_2_new_part char(3),
  bdl_2_old_cla char(4),
  bdl_2_old_part char(3),
  bdl_2_upd_dt char(7),
  bdl_2_upd_ti char(6),
  bdl_2_upd_uid char(5),
  PRIMARY KEY (gravity_pk)
  );
