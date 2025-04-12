# vm_startstop

## 使い方

- PowerShellスクリプト vm_startstop.ps1 を使用して、指定した曜日にVMを開始または停止します。
- 主なパラメータ:
  - Action: "start" または "stop"
  - ResourceGroupName: 対象リソースグループ名
  - DayOfWeek: 実行する曜日 ("Monday" など)
  - VMList: VM名のリスト (省略可)

実行例:

```powershell
.\vm_startstop.ps1 -Action start -ResourceGroupName MyRG -DayOfWeek Wednesday
```
