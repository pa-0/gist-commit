$json =  @"
{
    "variables": {
        "apiSiteName": "[concat(parameters('name'), 'Api')]"
    },
    "resources": [{
        "Name": "[variables('apiSiteName')]"
    }]
}
"@

$p = @{name="ToDo"}

(DoResolve $json $p).resources.name


# Prints
# ToDoApi