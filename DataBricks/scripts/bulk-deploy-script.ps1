param (
        [string]$folderPath,
        [string]$clusterId,
        [string]$permissionFolder
      )

$jobsJson = databricks jobs list --output JSON 2>&1
$jobs = $jobsJson | ConvertFrom-Json
# if ($jobs) {
#     foreach ($job in $jobs) {
#         $jobId = $job.job_id

#         # Deleting the job/workflow by job ID
#         databricks jobs delete $jobId

#         Write-Output "Deleted Job ID: $jobId"
#     }
#     Write-Output "All jobs have been deleted."
# } else {
#     Write-Output "No jobs found to delete."
# }
$files = Get-ChildItem -Path $folderPath -Filter *.json

foreach ($file in $files) {
    $json = Get-Content -Path $file.fullName | ConvertFrom-Json
    Write-Output $file
    $json.PSObject.Properties.Remove("run_as")
    foreach ($task in $json.tasks) {
        if($task.run_job_task.job_id){
            $job = $jobs | Where-Object { $_.settings.name -eq $task.task_key }
            $task.run_job_task.job_id = $job.job_id
        }
        if($task.existing_cluster_id){
            $task.existing_cluster_id = $clusterId
        }
        
    }
    $json | ConvertTo-Json -Depth 10 | Set-Content -Path $folderPath/$file
    $jobname = $jobs | Where-Object { $_.settings.name -eq $json.name }

    if($json.name -ne $jobname.settings.name){
        $jobCreateOutput=$(databricks jobs create --json @$folderPath/$file)
        $jobId = ($jobCreateOutput | ConvertFrom-Json).job_id
        Write-Output $jobId
        databricks jobs set-permissions $jobId --json @$permissionFolder
    }else {
        Write-Output $json.name+" "+"already exist"
    }
}
