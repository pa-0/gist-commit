function Open-GHWebEditor {
    <#
        .SYNOPSIS
        Opens the GitHub web editor on a repo.

        .EXAMPLE
        Open-GHWebEditor powerShell/powerShell
    #>
    param(
        [Parameter(Mandatory)]
        $slug
    )

    $url = "https://github.dev/$($slug)"

    Start-Process $url
}