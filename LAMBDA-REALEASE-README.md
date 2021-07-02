## To Release new version to Aws Lambda

### Manual release
- Run GHA WF "manual-release"
- Input required arguments, note that API version contains "-preview.x" will be deployed to Staging by default
- Check Release created with body contains string "for Relation Gem", i.e. "for Relation Gem v1.1.1"
- Check GHA WF "on-release" triggered to attach aws bundle to the Release