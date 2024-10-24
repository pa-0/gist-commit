. .\logger.ps1

Write-Log "Started" "INFO"

for ($i = 100; $i -gt 0; $i--) 
{ 
    Write-Log "debug message"
    Write-Log "debug message2" "DEBUG"
    Write-Log "info message" "INFO"
    Write-Log "warn message" "WARN"
    Write-Log "error message" "ERROR"
    Write-Log "fatal message" "FATAL"
    Write-Log "message with wrong level" "WRONG"
}
