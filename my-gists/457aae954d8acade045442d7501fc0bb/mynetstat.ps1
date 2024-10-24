function mynetstat {

$t=@"
  Proto  Local Address          Foreign Address        State
  {Proto*:TCP}    {Address:0.0.0.0:80}             {FA:my-laptop:0}            {State:LISTENING}
  TCP    0.0.0.0:135            my-laptop:0            LISTENING
  TCP    192.168.0.6:139        my-laptop:0            LISTENING
  {Proto*:TCP}    192.168.0.6:1128       a23-209-83-52:https    {State:CLOSE_WAIT}
"@
    $data | cfs -TemplateContent $t | select * -ExcludeProperty ExtentText 
}

