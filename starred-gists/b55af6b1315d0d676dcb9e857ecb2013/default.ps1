# Tasks for psake. Run with invoke-psake.

Task default -Depends TestPath, Minify

Task Minify -Depends MinifyWithRunspace

Task Build -Depends Clean {
    & hugo
}

Task Clean {
    'Removing everything from .\public\ folder'
    Remove-Item .\public\* -recurse
}

Task TestPath {
    $path = '.\public'
    if(test-path $path)
    {
        "$path folder found."
    }
    else
    {
        "Creating folder $path."
        "Put some content in there."
        New-Item -ItemType Directory -Force -Path $path
    }
}

Task MinifySequential {
    . .\minify-sequential.ps1
}


Task MinifyWithInvokeParallel {
    . .\minify-invokeparallel.ps1
}

Task MinifyWithJob {
    . .\minify-job.ps1
}

Task MinifyWithPoshRSJob {
    . .\minify-poshrsjob.ps1
}

Task MinifyWithRunspace {
    . .\minify-runspace.ps1
}

Task MinifyWithWorkflow {
    . .\minify-workflow.ps1
}


Task MinifyWithInvokeParallelSort {
    . .\minify-invokeparallel.ps1 -Sort
}

Task MinifyWithJobSort {
    . .\minify-job.ps1 -Sort
}

Task MinifyWithPoshRSJobSort {
    . .\minify-poshrsjob.ps1 -Sort
}

Task MinifyWithRunspaceSort {
    . .\minify-runspace.ps1 -Sort
}

Task MinifyWithWorkflowSort {
    . .\minify-workflow.ps1 -Sort
}
