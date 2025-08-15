# vm_startstop

## 使い方

- PowerShellスクリプト vm_startstop.ps1 を使用して、指定した曜日にVMを開始または停止します。
- 主なパラメータ:
  - Action: "start" または "stop"
  - ResourceGroupName: 対象リソースグループ名
  - DaysOfWeek: 実行する曜日 (カンマ区切りで複数指定可能、例: "Monday,Wednesday")
  - VMList: VM名のリスト (カンマ区切りで複数指定可能、省略可)

実行例:

```powershell
.\vm_startstop.ps1 -Action start -ResourceGroupName MyRG -DaysOfWeek Wednesday
```

特定のVMを指定する場合:

```powershell
.\vm_startstop.ps1 -Action stop -ResourceGroupName MyRG -DaysOfWeek Monday,Friday -VMList VM1,VM2
```
