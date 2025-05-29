import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function DeleteDeviceBuilder() {
  DeleteDevice()
}

@Component
struct DeleteDevice {
  @State pathStack: NavPathStack = new NavPathStack()
  @State number: string = ''
  @State deviceExists: boolean = false

  private async checkDevice() {
    if (!this.number) {
      promptAction.showToast({ message: '' })
      return
    }

    const device = await DeviceAPI.getDevice(this.number)
    this.deviceExists = !!device
    if (!this.deviceExists) {
      promptAction.showToast({ message: '设备不存在' })
    } else {
      promptAction.showToast({ message: '设备存在' })
    }
  }

  private async deleteDevice() {
    if (!this.deviceExists) {
      promptAction.showToast({ message: '请输入正确的设备编号' })
      return
    }
    try {
      const success = await DeviceAPI.deleteDevice(this.number)
      if (success) {
        promptAction.showToast({ message: '删除成功' })
        this.number = ''
      } else {
        promptAction.showToast({ message: '删除失败' })
      }
    } catch (err) {
      console.error('删除设备失败:', err)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('设备删除')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        Row() {
          TextInput({ placeholder: '请输入设备编号', text: this.number })
            .fontSize(20)
            .width('70%')
            .onChange(value => {
              this.number = value
              this.deviceExists = false
            })
            .margin({ right: 20 })
          Button('验证设备')
            .width('25%')
            .onClick(() => this.checkDevice())
        }
        .width('90%')
        .margin({ bottom: 20 })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.delete'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('删除')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('30%')
        .height(40)
        .onClick(() => this.deleteDevice())
        .margin({ top: 100 })
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}