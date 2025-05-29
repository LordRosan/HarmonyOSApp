import { EmergencyType } from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function FailureReportBuilder() {
  FailureReport()
}

@Component
struct FailureReport {
  @State pathStack: NavPathStack = new NavPathStack()
  @State deviceNumber: string = ''
  @State selectedDate: string = ''
  @State description: string = ''
  @State emergency: EmergencyType = EmergencyType.BLUE
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
      promptAction.showToast({ message: '故障描述不能为空' })
      return
    }

    if (!this.operator) {
      promptAction.showToast({ message: '操作员不能为空' })
      return
    }

    try {
      const success = await DeviceAPI.addFailureRecord({
        deviceNumber: this.deviceNumber,
        date: this.selectedDate,
        description: this.description,
        emergency: this.emergency,
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
        Text('故障报告提交')
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
          Text(this.selectedDate || '请选择故障日期')
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

        Text('紧急程度')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Column() {
          Row() {
            Radio({ value: EmergencyType.BLUE, group: 'emergencyGroup' })
              .checked(this.emergency === EmergencyType.BLUE)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.emergency = EmergencyType.BLUE
                }
              })
              .margin({ left: 10 })
            Text('蓝色等级-常规')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: EmergencyType.YELLOW, group: 'emergencyGroup' })
              .checked(this.emergency === EmergencyType.YELLOW)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.emergency = EmergencyType.YELLOW
                }
              })
              .margin({ left: 10 })
            Text('黄色等级-轻微')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: EmergencyType.ORANGE, group: 'emergencyGroup' })
              .checked(this.emergency === EmergencyType.ORANGE)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.emergency = EmergencyType.ORANGE
                }
              })
              .margin({ left: 10 })
            Text('橙色等级-中等')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: EmergencyType.RED, group: 'emergencyGroup' })
              .checked(this.emergency === EmergencyType.RED)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.emergency = EmergencyType.RED
                }
              })
              .margin({ left: 10 })
            Text('红色等级-严重')
              .margin({ right: 10 })
          }
        }
        .margin({ bottom: 20 })

        TextInput({ placeholder: '请输入故障信息', text: this.description })
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
            this.description = ''
            this.emergency = EmergencyType.BLUE
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