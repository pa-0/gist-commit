Get-Process -PipelineVariable process |
    ForEach-Object { $process.Modules } -PipelineVariable module |
    ForEach-Object { "process: {0} has module {1}" -f $process.Name, $module.ModuleName}