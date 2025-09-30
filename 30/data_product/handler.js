return {
  ...source,
  gravity_pk: source.bdl_id + source.bdl_ipd_no + source.bdl_in_dtti + source.bdl_pat_no + source.bdl_in_dtti_v,
}
