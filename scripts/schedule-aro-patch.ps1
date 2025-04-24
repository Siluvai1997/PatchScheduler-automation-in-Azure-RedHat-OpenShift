param (
    [string]$ScheduledDate
)

# Check current OpenShift version
$currentVersion = oc get clusterversion version -o jsonpath='{.status.desired.version}'
Write-Host "Current cluster version: $currentVersion"

# Get available patch versions
$availableVersions = oc get clusterversion version -o json | `
    ConvertFrom-Json | `
    Select-Object -ExpandProperty status | `
    Select-Object -ExpandProperty availableUpdates | `
    ForEach-Object { $_.version }

if (-not $availableVersions) {
    Write-Host "No patch updates available."
    exit 0
}

$latestPatch = $availableVersions | Sort-Object -Descending | Select-Object -First 1
Write-Host "Latest available patch version: $latestPatch"

# Check for existing upgrade config
$upgradeExists = oc get upgradeconfigs.upgrade.managed.openshift.io upgrade-config -n openshift-managed-upgrade-operator --ignore-not-found

if ($upgradeExists) {
    Write-Host "Upgrade config already exists. Aborting creation."
    exit 0
}

# Generate upgrade config YAML
$upgradeConfig = @"
apiVersion: upgrade.managed.openshift.io/v1
kind: UpgradeConfig
metadata:
  name: managed-upgrade-config
  namespace: openshift-managed-upgrade-operator
spec:
  desired:
    version: "$latestPatch"
    channel: stable-${currentVersion.Substring(0,4)}
  upgradeAt: "$ScheduledDate"
  type: ARO
  PDBForceDrainTimeout: 60
"@

# Write YAML and apply
$upgradeConfig | Out-File -FilePath upgrade-config.yaml -Encoding utf8
oc apply -f upgrade-config.yaml
Write-Host "Upgrade config created successfully. Patch scheduled for $ScheduledDate."
