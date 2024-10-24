function Test-ToolResources {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$ToolResources
    )

    if ($ToolResources.ContainsKey('code_interpreter')) {
        if ($ToolResources['code_interpreter'] -isnot [hashtable]) {
            throw "code_interpreter must be a hashtable"
        }

        if ($ToolResources['code_interpreter'].ContainsKey('file_ids')) {
            if ($ToolResources['code_interpreter']['file_ids'] -isnot [array]) {
                throw "file_ids must be an array"
            }
        }
    }

    if ($ToolResources.ContainsKey('file_search')) {
        if ($ToolResources['file_search'] -isnot [hashtable]) {
            throw "file_search must be a hashtable"
        }

        if ($ToolResources['file_search'].ContainsKey('vector_store_ids')) {
            if ($ToolResources['file_search']['vector_store_ids'] -isnot [array]) {
                throw "vector_store_ids must be an array"
            }
        }
    }

    if ($ToolResources.ContainsKey('vector_stores')) {
        if ($ToolResources['vector_stores'] -isnot [array]) {
            throw "vector_stores must be an array"
        }

        foreach ($vector_store in $ToolResources['vector_stores']) {
            if ($vector_store -isnot [hashtable]) {
                throw "vector_store must be a hashtable"
            }

            if ($vector_store.ContainsKey('file_ids')) {
                if ($vector_store['file_ids'] -isnot [array]) {
                    throw "file_ids must be an array"
                }
            }

            if ($vector_store.ContainsKey('metadata')) {
                if ($vector_store['metadata'] -isnot [hashtable]) {
                    throw "metadata must be a hashtable"
                }
            }
        }
    }
}