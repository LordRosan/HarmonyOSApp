import { RepairType } from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function RepairReportBuilder() {
  RepairReport()
}

@Component
struct RepairReport {
  @State pathStack: NavPathStack = new NavPathStack()
  @State deviceNumber: string = ''
  @State selectedDate: string = ''
  @State type: RepairType = RepairType.RegularCheck
  @State description: string = ''
  @State operator: string = ''
  @State deviceExists: boolean = false

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  private async checkDevice() {
    if (!this.deviceNumber) {
      promptAction.showToast({ message: '请输入设备编号' })
      return
    }

    const device = await DeviceAPI.getDevice(this.deviceNumber)
    this.deviceExists = !!device
    if (!this.deviceExists) {
      promptAction.showToast({ message: '设备不存在' })
    } else {
      promptAction.showToast({ message: '设备存在' })
    }
  }

  private async submitReport() {
    if (!this.deviceExists) {
      promptAction.showToast({ message: '请输入正确的设备编号' })
      return
    }

    if (!this.selectedDate) {
      promptAction.showToast({ message: '请选择日期' })
      return
    }

    if (!this.description) {
      promptAction.showToast({ message: '维修描述不能为空' })
      return
    }

    if (!this.operator) {
      promptAction.showToast({ message: '操作员不能为空' })
      return
    }

    try {
      const success = await DeviceAPI.addRepairRecord({
        deviceNumber: this.deviceNumber,
        date: this.selectedDate,
        type: this.type,
        description: this.description,
        operator: this.operator
      })
      if (success) {
        promptAction.showToast({ message: '提交成功' })
      } else {
        promptAction.showToast({ message: '提交失败' })
      }
    } catch (err) {
      console.error('提交报告异常', err)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('维修报告提交')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        Row() {
          TextInput({ placeholder: '请输入设备编号', text: this.deviceNumber })
            .fontSize(20)
            .width('70%')
            .onChange(value => {
              this.deviceNumber = value
              this.deviceExists = false
            })
            .margin({ right: 20 })
          Button('验证设备')
            .width('25%')
            .onClick(() => this.checkDevice())
        }
        .width('90%')
        .margin({ bottom: 20 })

        Row() {
          Text(this.selectedDate || '请选择维修日期')
            .fontSize(20)
            .fontColor(this.selectedDate ? Color.Black : Color.Gray)
          Image($r('app.media.calendar'))
            .width(20)
            .height(20)
            .margin({ left: 10 })
        }
        .onClick(() => {
          CalendarPickerDialog.show({
            selected: this.selectedDate ? new Date(this.selectedDate) : new Date(),
            onAccept: (date: Date) => {
              this.selectedDate = this.formatDate(date)
            },
            acceptButtonStyle: { type: ButtonType.Capsule },
            cancelButtonStyle: { type: ButtonType.Capsule }
          })
        })
        .margin({ bottom: 20 })

        Text('维修类型')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Column() {
          Row() {
            Radio({ value: RepairType.RegularCheck, group: 'repairTypeGroup' })
              .checked(this.type === RepairType.RegularCheck)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = RepairType.RegularCheck
                }
              })
              .margin({ left: 10 })
            Text('常规检查')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: RepairType.FailureRepair, group: 'repairTypeGroup' })
              .checked(this.type === RepairType.FailureRepair)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = RepairType.FailureRepair
                }
              })
              .margin({ left: 10 })
            Text('故障维修')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: RepairType.UpdateAndUpgrade, group: 'repairTypeGroup' })
              .checked(this.type === RepairType.UpdateAndUpgrade)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = RepairType.UpdateAndUpgrade
                }
              })
              .margin({ left: 10 })
            Text('更新升级')
              .margin({ right: 10 })
          }
        }
        .margin({ bottom: 20 })

        TextInput({ placeholder: '请输入维修信息', text: this.description })
          .fontSize(20)
          .width('90%')
          .height(100)
          .onChange(value => this.description = value)
          .margin({ bottom: 20 })

        TextInput({ placeholder: '请输入操作员姓名', text: this.operator })
          .fontSize(20)
          .width('90%')
          .onChange(value => this.operator = value)
          .margin({ bottom: 20 })

        Row() {
          Button({ stateEffect: true, type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.reset'))
                .width(20)
                .height(20)
                .margin({ left: 10 })
              Text('重置')
                .fontSize(20)
                .fontColor(Color.White)
                .margin({ left: 15, right: 10 })
            }.alignItems(VerticalAlign.Center)
          }
          .width('30%')
          .height(40)
          .onClick(() => {
            this.deviceNumber = ''
            this.selectedDate = ''
            this.type = RepairType.RegularCheck
            this.description = ''
            this.operator = ''
            this.deviceExists = false
          })
          .margin({ right: 20 })

          Button({ stateEffect: true, type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.submit'))
                .width(20)
                .height(20)
                .margin({ left: 10 })
              Text('提交')
                .fontSize(20)
                .fontColor(Color.White)
                .margin({ left: 15, right: 10 })
            }.alignItems(VerticalAlign.Center)
          }
          .width('30%')
          .height(40)
          .onClick(() => this.submitReport())
          .margin({ left: 20 })
        }
        .margin({ top: 30 })
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}