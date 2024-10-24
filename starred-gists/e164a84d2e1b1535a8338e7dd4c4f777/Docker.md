To remove all stopped containers:
``` powershell
docker ps --filter "status=exited" --format "{{.ID}}" | foreach { docker rm $_ }
```