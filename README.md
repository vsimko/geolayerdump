# geolayerdump


## Incremental snapshots using **duplicity**:
``` sh
duplicity -vi \
  --allow-source-mismatch \
  --no-encryption \
  path/to/my/source/dir file://path/to/my/snapshot/dir
```

- `-vi` = verbosity level is "info"
- `--allow-source-mismatch` allows that the names of source dirs can be changed

## Listing existing snapshots
``` sh
duplicity colletion-status file://path/to/my/snapshot/dir
```

## Restoring a snapshot
``` sh
duplicity restore file://path/to/my/snapshot/dir /path/to/output/dir
```
