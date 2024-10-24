class SemanticVersionExtended {
    <#
    .SYNOPSIS
        Represents a Semantic Version (SemVer).

    .LINK
        https://gist.github.com/jpawlowski/1c81fff8a55f5e368d831e60e235893c
    #>
    [int]$Major
    [int]$Minor
    [int]$Patch
    [System.Collections.ArrayList]$PreReleaseLabel
    [System.Collections.ArrayList]$BuildLabel
    [hashtable]$PreReleaseLabelDict
    [hashtable]$BuildLabelDict

    <#
    .SYNOPSIS
        Creates a new instance of the SemanticVersionExtended class.
    #>
    SemanticVersionExtended([int]$Major, [int]$Minor, [int]$Patch, $PreReleaseLabel, $BuildLabel, [bool]$CreateDict = $false) {
        $this.Major = $Major
        $this.Minor = $Minor
        $this.Patch = $Patch

        $this.PreReleaseLabel = New-Object System.Collections.ArrayList
        $this.ProcessLabel($PreReleaseLabel, $this.PreReleaseLabel)

        $this.BuildLabel = New-Object System.Collections.ArrayList
        $this.ProcessLabel($BuildLabel, $this.BuildLabel)

        if ($CreateDict) {
            $date = New-Object DateTime
            $this.PreReleaseLabelDict = $this.CreateLabelDict($this.PreReleaseLabel, $date)
            $this.BuildLabelDict = $this.CreateLabelDict($this.BuildLabel, $date)
        }
    }

    hidden [void] ProcessLabel($label, [System.Collections.ArrayList]$labelList) {
        if ($label -is [array]) {
            foreach ($item in $label) {
                if ($item -is [string]) {
                    $this.ProcessItem($item, $labelList)
                }
                else {
                    throw "Invalid label value of type: $($item.GetType().FullName)"
                }
            }
        }
        elseif ($label -is [string]) {
            $this.ProcessItem($label, $labelList)
        }
        else {
            throw "Invalid label value of type: $($label.GetType().FullName)"
        }
    }

    hidden [void] ProcessItem([string]$item, [System.Collections.ArrayList]$labelList) {
        $splitResult = $item.Split('.')
        foreach ($item in $splitResult) {
            [void]$labelList.Add($item)
        }
    }

    hidden [hashtable] CreateLabelDict([System.Collections.ArrayList]$labelList, [DateTime]$date) {
        $dict = @{}
        if ($labelList.Count % 2 -eq 0) {
            for ($i = 0; $i -lt $labelList.Count; $i += 2) {
                if ($labelList[$i + 1] -match '^\d+$') {
                    [void]$labelList.Add([int]$labelList[$i + 1])
                }
                elseif ($labelList[$i + 1] -eq 'true' -or $labelList[$i + 1] -eq 'false') {
                    [void]$labelList.Add([bool]::Parse($labelList[$i + 1]))
                }
                elseif ([DateTime]::TryParse($labelList[$i + 1], [ref]$date)) {
                    $dict[$labelList[$i]] = $date
                }
                else {
                    $dict[$labelList[$i]] = $labelList[$i + 1]
                }
            }
        }
        return $dict
    }

    <#
    .SYNOPSIS
        Converts the pre-release label to a string.
    #>
    [string] PreReleaseLabelToString() {
        if ($this.PreReleaseLabel) {
            return "-$($this.PreReleaseLabel -join '.')"
        }
        else { return '' }
    }

    <#
    .SYNOPSIS
        Converts the build label to a string.
    #>
    [string] BuildLabelToString() {
        if ($this.BuildLabel) {
            return "+($this.BuildLabel -join '.')"
        }
        else { return '' }
    }

    <#
    .SYNOPSIS
        Converts the SemanticVersionExtended object to a semantic version compatible string.
    #>
    [string] ToString() {
        $preRelease = $this.PreReleaseLabelToString()
        $build = $this.BuildLabelToString()
        return "$($this.Major).$($this.Minor).$($this.Patch)$preRelease$build"
    }

    <#
    .SYNOPSIS
        Parses a Semantic Version (SemVer) string.

    .DESCRIPTION
        This function parses a version string and returns a SemanticVersionExtended object.
        The version string could be in the format 'Major.Minor.Patch-PreReleaseLabel+BuildLabel' or 'Major.Minor.Patch.Revision' or a mix of it.
        Some common prefixes like 'v' or '<SHA265> refs/tags/v' or 'Version:' are automatically removed.

    .PARAMETER versionString
        The version string to parse.

    .PARAMETER asString
        If specified, the function returns the version as a string.

    .PARAMETER createDict
        If specified, the function creates a dictionary for the pre-release and build labels.
    #>
    static [object] Parse([string]$versionString, [bool]$asString = $false, [bool]$createDict = $false) {
        if ($null -ne $Matches) { $Matches.Clear() }
        $null = $versionString -match '^(?:.*refs\/tags\/v|.*Version *:? *|v)?(?<Major>\d+)(?:(?:\.(?<Minor>\d+))?(?:(?:\.(?<Patch>\d+))?(?:\.(?<Revision>\d+))?)?)?(?:-(?<PreReleaseLabel>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+(?<BuildLabel>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$'
        if ($Matches.Count -eq 0) {
            Write-Error "Invalid version string: $versionString" -ErrorAction Stop
        }
        $lMajor = [int]$Matches['Major']
        $lMinor = if ($null -ne $Matches['Minor']) { [int]$Matches['Minor'] } else { 0 }
        $lPatch = if ($null -ne $Matches['Patch']) { [int]$Matches['Patch'] } else { 0 }
        $lRevision = if ($null -ne $Matches['Revision']) { [int]$Matches['Revision'] }
        $lPreReleaseLabel = if ($null -ne $Matches['PreReleaseLabel']) { $Matches['PreReleaseLabel'] } else { '' }
        $lBuildLabel = if ($null -ne $Matches['BuildLabel']) { $Matches['BuildLabel'] } else { '' }

        if ($null -ne $lRevision -and $lBuildLabel -notmatch '^Rev(?:ision)?\.\d+') {
            $lBuildLabel = "Rev.$lRevision$lBuildLabel"
        }

        if ($asString) {
            return "$lMajor.$lMinor.$lPatch$(if ($lPreReleaseLabel) { "-$lPreReleaseLabel" })$(if ($lBuildLabel) { "+$lBuildLabel" })"
        }
        else {
            return [SemanticVersionExtended]::new($lMajor, $lMinor, $lPatch, $lPreReleaseLabel, $lBuildLabel, $createDict)
        }
    }

    <#
    .SYNOPSIS
        Compares two version strings. Returns a negative number if $v1 is less than $v2, zero if $v1 is equal to $v2, or a positive number if $v1 is greater than $v2.
        Can be used in the [Array]::Sort method as a custom comparer.

    .DESCRIPTION
        This function compares two SemVer version strings and returns:
        - a negative number if $v1 is less than $v2
        - zero if $v1 is equal to $v2
        - a positive number if $v1 is greater than $v2
        In other words, if the function returns a positive number, $v1 is the newer version.
    #>
    static [int] Compare($v1, $v2) {
        $semVer1 = $null
        $semVer2 = $null

        try {
            # Convert the version strings to SemanticVersionExtended objects
            $semVer1 = if ($v1 -is [SemanticVersionExtended]) { $v1 } elseif ($v1 -is [string]) { [SemanticVersionExtended]::Parse($v1, $false, $false) } else { Write-Error "Invalid type for version 1: $($v1.GetType().FullName)" -ErrorAction Stop }
            $semVer2 = if ($v2 -is [SemanticVersionExtended]) { $v2 } elseif ($v2 -is [string]) { [SemanticVersionExtended]::Parse($v2, $false, $false) } else { Write-Error "Invalid type for version 2: $($v2.GetType().FullName)" -ErrorAction Stop }
        }
        catch {
            Write-Error $_.Exception.Message -ErrorAction Stop
        }

        # Compare the major, minor, and patch versions
        foreach ($part in 'Major', 'Minor', 'Patch') {
            if ($semVer1.$part -ne $semVer2.$part) {
                return $semVer1.$part - $semVer2.$part
            }
        }

        # Compare the revision if it exists
        if ($semVer1.BuildLabel -and $semVer2.BuildLabel) {
            $revision1 = if ($semVer1.BuildLabel -match '^Rev(?:ision)?\.(\d+)') { [int]$matches[1] } else { $null }
            $revision2 = if ($semVer2.BuildLabel -match '^Rev(?:ision)?\.(\d+)') { [int]$matches[1] } else { $null }
            if ($null -ne $revision1 -and $null -ne $revision2) {
                if ($revision1 -ne $revision2) {
                    return $revision1 - $revision2
                }
            }
        }

        # If one version has a pre-release tag and the other doesn't, the one without is greater
        if ($semVer1.PreReleaseLabel -and !$semVer2.PreReleaseLabel) { return -1 }
        if (!$semVer1.PreReleaseLabel -and $semVer2.PreReleaseLabel) { return 1 }

        # If both versions have pre-release tags, compare them
        if ($semVer1.PreReleaseLabel -and $semVer2.PreReleaseLabel) {
            # Compare each part of the pre-release tag
            for ($i = 0; $i -lt [Math]::Max($semVer1.PreReleaseLabel.Count, $semVer2.PreReleaseLabel.Count); $i++) {
                # If one pre-release tag is shorter and all previous parts are equal, it is smaller
                if ($i -ge $semVer1.PreReleaseLabel.Count) { return -1 }
                if ($i -ge $semVer2.PreReleaseLabel.Count) { return 1 }

                # If both parts are numeric, compare them numerically
                if ($semVer1.PreReleaseLabel[$i] -match '^\d+$' -and $semVer2.PreReleaseLabel[$i] -match '^\d+$') {
                    if ([int]$semVer1.PreReleaseLabel[$i] -ne [int]$semVer2.PreReleaseLabel[$i]) {
                        return [int]$semVer1.PreReleaseLabel[$i] - [int]$semVer2.PreReleaseLabel[$i]
                    }
                }
                # If one part is numeric and the other isn't, the numeric one is smaller
                elseif ($semVer1.PreReleaseLabel[$i] -match '^\d+$') {
                    return -1
                }
                elseif ($semVer2.PreReleaseLabel[$i] -match '^\d+$') {
                    return 1
                }
                # If both parts are non-numeric, compare them lexicographically
                elseif ($semVer1.PreReleaseLabel[$i] -ne $semVer2.PreReleaseLabel[$i]) {
                    if ($semVer1.PreReleaseLabel[$i] -lt $semVer2.PreReleaseLabel[$i]) { return -1 }
                    if ($semVer1.PreReleaseLabel[$i] -gt $semVer2.PreReleaseLabel[$i]) { return 1 }
                }
            }
        }

        # If all parts are equal, the versions are equal
        return 0
    }

    <#
    .SYNOPSIS
        Sorts an array of version strings.
    #>
    static [string[]] SortVersions([string[]]$versions) {
        # Define a custom comparer
        $comparer = [System.Collections.Generic.Comparer[Object]]::Create({
                param($v1, $v2)
                return [SemanticVersionExtended]::Compare($v1, $v2)
            })

        # Sort the array using the custom comparer
        try {
            [Array]::Sort($versions, $comparer)
        }
        catch {
            Write-Error "Failed to sort versions: $($_.Exception.Message)" -ErrorAction Stop
        }

        # Output each sorted version
        return $versions
    }
}
