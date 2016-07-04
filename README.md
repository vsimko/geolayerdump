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


## Rename stuff by removing prefix from filename
Assuming you are in some directory which contains files and the prefix is "PREFIX"
(This is just a quick and dirty method, there is certainly a better way to do so)
```
find . | while read F; do mv $F ${F#./PREFIX}; done
```
