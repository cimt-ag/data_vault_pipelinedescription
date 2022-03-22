# Release 0.3.0
## new features
- automated tests for hash content mapping
- provide process list (changes some naming in HK)
- handling of recursion declaration and field groups is ok so far (needs more testing)

## refactoring
better naming for some elements

| old | better |
| -------------- | ------------------ |
| is_encrypted | needs_encryption |
| hierarchical | recursive |
| prio_in_hashkey | prio_in_key_hash |  

## bugfixes
- incompatbles usage of json_array_elements_text in a case clause in DVPD_PIPELINE_FIELD_TARGET_EXPANSION