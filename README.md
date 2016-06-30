# geolayerdump

Incremental snapshots of the dumps using **duplicity**:

``` sh
duplicity -vi \
  --allow-source-mismatch \
  --no-encryption \
  path/to/my/source/dir file://path/to/my/snapshot/dir
```

- `-vi` = verbosity level is "info"
- `--allow-source-mismatch` allows that the names of source dirs can be changed
