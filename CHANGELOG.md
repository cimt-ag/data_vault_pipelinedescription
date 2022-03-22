# Release 0.3.0
-  Refactoring to better names
| old | better |
|--------------|------------------|
| is_encrypted | needs_encryption |
| hierarchical | recursive |
| prio_in_hashkey | prio_in_key_hash |  

- automated tests for hash content mapping
- provide process list (changes some naming in HK)
- handling of recursion declaration and field groups is ok so far (needs more testing)