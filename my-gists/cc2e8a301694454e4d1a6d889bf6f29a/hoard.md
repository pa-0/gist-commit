# WSL

**Recover unused cached memory**
```sh
echo 1 > /proc/sys/vm/drop_caches
```

**Export in `.vhdx` format**

```powershell
wsl.exe --shutdown
cd ~
wsl.exe --export Ubuntu --vhd .\Pengwin\backups\ubuntu.vhdx
```

**Import in `.vhdx` format**

```powershell
cd ~
wsl.exe --import Ubuntu Ubuntu .\Pengwin\backups\ubuntu.vhdx --vhd
```

**Export in `.tgz` format (legacy)**

```powershell
cd ~
wsl.exe --export Ubuntu .\Pengwin\backups\ubuntu.tgz
```

**Import in `.tgz` format (legacy)**

```powershell
cd ~
wsl.exe --import Ubuntu Ubuntu .\Pengwin\backups\ubuntu.tgz
```

# Docker

**Start `dockerd` with `start-stop-daemon`**

```sh
sudo start-stop-daemon -b --exec $(which dockerd) --start -- -G $(whoami)
```

**Delete all images**

```sh
docker rmi -f $(docker images -a -q)
```

# AWS

## EC2

**Add public key**

See doc here: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/describe-keys.html#retrieving-the-public-key

```sh
mkdir -p ~/.ssh
curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key >> ~/.ssh/authorized_keys
```

# MSI

## Infrastructure

**Run `ansible-playbook` against a host**

```sh
# pip install ansible
AWS_PROFILE=${pod} ansible-playbook -i ansible/inventories/${pod}/hosts.yml --limit ${host}.ec2.${pod}.activeeye.com ansible/site.yml
```

**Prune a host from SFT**

```sh
ssh jenkins2.ec2.hawk.activeeye.com sftpruner --project ${pod} --hostname ${host}.ec2.${pod}.activeeye.com --ip ${ip}
```

## Backend

**Cancel AERSS secret rotation**

```sh
python $backend/src/aerss-password-rotator/secret_scope.py <pod> AERSS/<client_module_id> list_versions
python $backend.src/aerss-password-rotator/secret_scope.py <pod> AERSS/<client_module_id> remove_label --version-id <version_id> --label AWSPENDING
```

**Deploy a lambda version across all known pods**

```sh
build/lambda/production.sh ${app} v${version} wasp
build/lambda/production.sh ${app} v${version} lion
build/lambda/production.sh ${app} v${version} bear
build/lambda/production.sh ${app} v${version} seal
build/lambda/production.sh ${app} v${version} wren
build/lambda/production.sh ${app} v${version} orca
build/lambda/production.sh ${app} v${version} wolf
```

**Read an ingest file**

```sh
aws --profile=${pod} s3 cp ${s3_path} - | gzip -d | jq -r .Data.body.body | base64 -d | jq
```

## Report Runner

**Run test reports in wasp**

```sh
ssh reportrunner1.ec2.wasp.activeeye.com

sudo su - reports

export AWS_REGION=`curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'`
cd /opt/report-runner/current
python3.9 report_scheduler/report_scheduler.py -config /etc/report-runner/report-runner -test-reports
```

**Run monthly reports in lion**

Take a look at this secret in lion `arn:aws:secretsmanager:us-east-1:754700948275:secret:reportrunner/cfg-b5Qbyy`
Append your email to the `monthly_email_recipients` field (it's a CSV).

```sh
ssh reportrunner1.ec2.lion.activeeye.com

sudo su - reports

export AWS_REGION=`curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'`
cd /opt/report-runner/current
python3.9 soc_monthly_metrics.py -config /etc/report-runner/report-runner.cfg -customers deltarisks
```

## FAPIv1-2

**Obtain the auth token for v1**

```fish
set TOKEN (curl -s -X POST -H "X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth" -H "Content-Type: application/x-amz-json-1.1" -d '{"AuthParameters": { "USERNAME": "factory1", "PASSWORD": "..." }, "AuthFlow": "USER_PASSWORD_AUTH", "ClientId": "6urmkc7gcaopu336crs4q32tuj"}' "https://cognito-idp.us-east-1.amazonaws.com" | jq -r .AuthenticationResult.AccessToken)
set FAPI_VERSION v1
set FAPI_ENDPOINT https://api.provisioning.activeeye.com
```

**Obtain the auth token for v2**
```fish
set TOKEN ...  # see https://dash.op.activeeye.com/fapi/v2
set FAPI_VERSION v2
set FAPI_ENDPOINT https://api.provisioning.activeeye.com
```

**Commonly used actions**

```sh
curl -H "Authorization: Bearer $TOKEN" "$FAPI_ENDPOINT/$FAPI_VERSION/whoami"  # available since v2
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$ESN&son=11111111&region=us"  # lion / bear / wolf
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$(uuidgen)&son=11111111&region=us"  # lion / bear / wolf
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$ESN&son=11111111&region=stage"  # wasp / orca
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$(uuidgen)&son=11111111&region=stage"  # wasp / orca
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$ESN&son=11111111&region=dev"  # pimepafmst
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/create_device?cust_id=aeye&esn=$(uuidgen)&son=11111111&region=dev"  # pimepafmst
curl -H "Authorization: Bearer $TOKEN" "$FAPI_ENDPOINT/$FAPI_VERSION/register_device?lsn=$LSN"
curl -H "Authorization: Bearer $TOKEN" "$FAPI_ENDPOINT/$FAPI_VERSION/get_csh_status?lsn=$LSN"
curl -H "Authorization: Bearer $TOKEN" -X POST "$FAPI_ENDPOINT/$FAPI_VERSION/complete_device_build?lsn=$LSN"
curl -H "Authorization: Bearer $TOKEN" -X DELETE "$FAPI_ENDPOINT/$FAPI_VERSION/delete_device?lsn=$LSN&delete_csh_record=true"
```

## BitBucket

**List all projects**

```sh
msi-init
curl -K iap.header https://bitbucket.mot-solutions.com/rest/api/1.0/projects
```

## AERSS

**Retrieve CMEP default passwords**

```sh
aws --profile=op secretsmanager get-secret-value --secret-id=dev/jenkins/cmep_admin | jq -r .SecretString
```

**Retrieve password for logs fetched via op-dash**

```sh
aws --profile=op secretsmanager get-secret-value --secret-id=aerss/logs | jq -r .SecretString | jq -r .password
```

**Fetch logs**

as root on AERSS

```sh
/opt/Motorola/ssp/ssp_log_collector.py get
# --host if you want to include host logs
# --passwd=YWJjZAo= if you want a password (base64 encoded)
# --upload if you want to push to CSH

cp /ssp_disks/ssp_app/log_collector/*.xz /home/admin
chown admin:admin /home/admin/*.xz
```

on host
```sh
scp -o PreferredAuthentications=password "admin@aerss.activeeye:~/*.xz" ~/
```

as admin on AERSS
```sh
rm -f /home/admin/*.xz
```

as root
```sh
/opt/Motorola/ssp/ssp_log_collector.py rm
```

**Manual Switchover**

as root
```sh
systemctl start rollback_trigger
systemctl status nubis_initializer
systemctl status rollback_timer
```

## Dashboard

**Add a user to SSO**

When connected to CORP network on MSI-imaged laptop.
`GROUP=activeeye-<pod>-users`

```powershell
net group <GROUP> <CORE_ID> /add /domain
```

```sh
# prereq
sudo apt install -y samba-common-bin
# add member
GROUP=
CORE_ID=
ADMIN_CORE_ID=
ADMIN_PASSWORD=
# check if member is in group
net rpc group members $GROUP --server=ds.mot.com -U $ADMIN_CORE_ID%$ADMIN_PASSWORD | grep -i $CORE_ID
# if not, add
net rpc group addmem $GROUP $CORE_ID --server=ds.mot.com -U $ADMIN_CORE_ID%$ADMIN_PASSWORD
```

# Tenable

**Install a Nessus agent**

```sh
curl -H "X-Key: ${TENABLE_LINKING_KEY}" "https://cloud.tenable.com/install/agent?name=$(hostname)&groups=$(hostname | cut -d. -f3)" | sudo bash -
```

**Check Nessus agent status**

```sh
sudo /opt/nessus_agent/sbin/nessuscli agent status
```

# PowerShell

**Edit command in external editor**

```powershell
Set-PSReadLineKeyHandler -Chord Alt+e -Function ViEditVisually
$env:VISUAL='notepad'
```

Cannot use VSCode due to https://github.com/PowerShell/PSReadLine/issues/3214.

# Ubuntu / Debian

**Manage repository keys**

Ubuntu doesn’t want you to add all the signature keys in the single `/etc/apt/trusted.gpg` file. It suggests using a separate file that are located in the `/etc/apt/trusted.gpg.d` directory.

It’s the same mechanism it uses for the sources list where external repository sources are listed in their own file under `/etc/apt/sources.list.d` instead of keeping everything under the `/etc/apt/sources.list` file. It makes managing the external repos a bit easier.

This means that instead of using the `apt-key` in this fashion:
```sh
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add -
```

You should use it like this:
```
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/spotify.gpg
```

**Release upgrade**

Note that on Ubuntu Server, the new LTS release isn't made available to `do-release-upgrade` until its first point release, such as `22.04.1`. This usually comes a few months after the initial release date.

If you don't see an available release, add the `-d` option to upgrade to the development release.

```sh
sudo do-release-upgrade [-d]
```

**Reboot to UEFI**

```sh
sudo systemctl reboot --firmware-setup
```

**Laptop Close-Lid Behaviors**

If you look into the content of the file `/etc/systemd/logind.conf`, you’ll see three different types of default settings for the laptop lid closing.

- `HandleLidSwitch`: When the laptop is on battery power
- `HandleLidSwitchExternalPower`: When the laptop is plugged into a power outlet
- `HandleLidSwitchDocked`: When the laptop is connected to a docking station

If you want, you can change the value of those parameters to one of these as per your preference:

- `lock`: lock when lid is closed
- `ignore`: do nothing
- `poweroff`: shutdown
- `hibernate`: hibernate when lid is closed

You can either edit the `/etc/systemd/logind.conf` file and uncomment the said settings and change their value, or you create a new file in `/etc/systemd/logind.conf.d` directory. Create this directory if it doesn’t exist.

**Podman rootless**

We need the `newuidmap` and `newgidmap` binaries, which can be obtained with

```sh
sudo apt install -y uidmap
```
