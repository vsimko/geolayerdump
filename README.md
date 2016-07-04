# geolayerdump


## Incremental snapshots using **duplicity**:
```
duplicity -vi --allow-source-mismatch --no-encryption path/to/src/dir file://path/to/snapshot/dir
```
- `-vi` = verbosity level is "info"
- `--allow-source-mismatch` allows that the names of source dirs can be changed

## Listing existing snapshots
```
duplicity colletion-status file://path/to/my/snapshot/dir
```

## Restoring a snapshot
```
duplicity restore --no-encryption --time 2016-06-30T11:00:00 file://path/to/snapshot/dir path/to/output/dir
```
