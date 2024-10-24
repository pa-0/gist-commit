using namespace "Microsoft.DotNet.Interactive"

function Write-Notebook {
    <#
        .SYNOPSIS
          Writes to  the output part of the current cell (a streamlined version of Out-Display)
  
        .PARAMETER Html
          Output to be sent as Hmtl
  
        .PARAMETER Text
          Output to be sent as plain text
  
        .PARAMETER PassThru
          If specified returns the output object, allowing it to be updated.
  
        .EXAMPLE
          > $statusMsg = Write-Notebook -PassThru -text  "Step 1"
          > ...
          > $statusmsg.update("Step2")
  
          Displays and updates text in the current cell output
  
        .EXAMPLE
          >  $PSVersionTable | ConvertTo-Html -Fragment | Write-Notebook
  
          Converts $psversionTable to a table and displays it. Without Write-Notebook the HTML markup would appear.
      #>
    [cmdletbinding(DefaultParameterSetName = 'Html')]
    param   (
      [parameter(Mandatory = $true, ParameterSetName = 'Html', ValueFromPipeline = $true, Position = 1 )]
      $Html,
  
      [parameter(Mandatory = $true, ParameterSetName = 'Text')]
      $Text,
  
      [Alias('PT')]
      [switch]$PassThru
    )
    begin { $htmlbody = @() }
    process { if ($html) { $htmlbody += $Html } }
    end {
      if ($htmlbody.count -gt 0) { $result = [Kernel]::display([Kernel]::HTML($htmlbody), 'text/html') }
      if ($Text) { $result = [Kernel]::display($Text, 'text/plain') }
      if ($PassThru) { return $result }
    }
  }

  function Out-Mermaid {
    <#
        .DESCRIPTION
          Accepts a mermaid chart definition as a parameter (example with the definition) or from the  pipeline
          and outputs the minimum correct HTML / Javascript but  **depends on the kernel extension being loaded**
  
          For examples see the mermaid home page at https://mermaid-js.github.io/mermaid/#/
          Has an alias of `Mermaid` it can be called in a more dsl-y style);
  
          .EXAMPLE
          ps >bMermaid @'
          sequenceDiagram
              participant Alice
              participant Bob
              Alice->>John: Hello John, how are you?
              loop Healthcheck
                  John->>John: Fight against hypochondria
              end
              Note right of John: Rational thoughts <br/>prevail!
              John-->>Alice: Great!
              John->>Bob: How about you?
              Bob-->>John: Jolly good!
          '@
  
          Outputs a sample diagram found on the mermaid home page
      #>
    [alias('Mermaid')]
    param   (
      [parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
      $Text
    )
    begin {
      $mermaid = ""
      $guid = ([guid]::NewGuid().ToString() -replace '\W', '')
      $html = @"
  <div style="background-color:white;"><script type="text/javascript">
  loadMermaid_$guid = () => {(require.config({ 'paths': { 'context': '1.0.252001', 'mermaidUri' : 'https://colombod.github.io/dotnet-interactive-cdn/extensionlab/1.0.252001/mermaid/mermaidapi', 'urlArgs': 'cacheBuster=7de2aec4927849b5a989d2305cf957bc' }}) || require)(['mermaidUri'], (mermaid) => {let renderTarget = document.getElementById('$guid'); mermaid.render( 'mermaid_$guid', ``~~Mermaid~~``, g => {renderTarget.innerHTML = g  });}, (error) => {console.log(error);});}
  if ((typeof(require) !==  typeof(Function)) || (typeof(require.config) !== typeof(Function))) {
      let require_script = document.createElement('script');
      require_script.setAttribute('src', 'https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js');
      require_script.setAttribute('type', 'text/javascript');
      require_script.onload = function() {loadMermaid_$guid();};
      document.getElementsByTagName('head')[0].appendChild(require_script);
  }
  else {loadMermaid_$guid();}
  </script><div id="$guid"></div></div>
"@
}
    process { $Mermaid += ("`r`n" + $Text -replace '^[\r\n]+', '' -replace '[\r\n]+$', '') }
    end { Write-Notebook -Html  ($html -replace '~~Mermaid~~', $mermaid ) }
  }