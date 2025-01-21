param (
        [string]$filePath,
        [string]$clusterId,
        [string]$permissionFolder
      )

$jobsJson = databricks jobs list --output JSON 2>&1
$jobs = $jobsJson | ConvertFrom-Json
$json = Get-Content -Path $filePath | ConvertFrom-Json
$job = $jobs | Where-Object { $_.settings.name -eq $json.name }

$jobGetOutput=$(databricks jobs get $job.job_id)
$updateSettings = $jobGetOutput | ConvertFrom-Json
$updateSettings | Add-Member -MemberType NoteProperty -Name "new_settings" -Value $json -Force
$updateSettings.PSObject.Properties.Remove("settings")

if ($job) {
    foreach ($task in $updateSettings.settings.tasks) {
        if($task.run_job_task.job_id){
            $job = $jobs | Where-Object { $_.settings.name -eq $task.task_key }
            $task.run_job_task.job_id = $job.job_id
        }
        if($task.existing_cluster_id){
            $task.existing_cluster_id = $clusterId
        }
        
    }
    Write-Output "update settings ready"
    $updateSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath
    databricks jobs reset --json @$filePath
    Write-Output "reset completed"

} else {
    Write-Output "No jobs found"
}
