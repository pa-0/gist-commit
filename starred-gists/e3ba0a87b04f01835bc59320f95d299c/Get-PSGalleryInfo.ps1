function Get-PSGalleryInfo {
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]        
        $Name
    )
    Begin {
$t = @"
{Name*:PowerShellISE-preview} {[version]Version:5.1.0.1} (this version) {[double]Downloads:885} {[DateTime]PublishDate:Wednesday, January 27 2016}
{Name*:ImportExcel} 1.97  {Downloads:106} Monday, January 18 2016 
"@
    }

    Process {
        $url ="https://www.powershellgallery.com/packages/$Name/"
        
        $r=iwr $url
        ($r.AllElements | ? {$_.class -match 'versionTableRow'}).innertext |
            ConvertFrom-String -TemplateContent $t
    }
}