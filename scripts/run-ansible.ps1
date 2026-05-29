Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AnsibleDir = Resolve-Path (Join-Path $ScriptRoot "..\ansible")

Set-Location $AnsibleDir
ansible-playbook -i inventory.ini playbook.yml
