import { RouteParam } from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function DeviceNumberQueryBuilder() {
  DeviceNumberQuery()
}

@Component
struct DeviceNumberQuery {
  //
  @State pathStack: NavPathStack = new NavPathStack()
  @State deviceNumber: string = ''

  private async queryDevice() {
    const deviceNumber = this.deviceNumber.trim()
    if (!/^\d{6}$/.test(deviceNumber)) {
      promptAction.showToast({ message: '请输入正确的设备编号' })
      return
    }
    try {
      const device = await DeviceAPI.getDevice(deviceNumber)
      if (!device) {
        promptAction.showToast({ message: '未查询到对应设备' })
        return
      }
      const routeParam: RouteParam = { deviceData: JSON.stringify(device) }
      this.pathStack.pushPathByName('DeviceDetail', routeParam)
    } catch (err) {
      promptAction.showToast({ message: '查询设备失败' })
      console.error('查询设备失败:', err)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text("设备编号查询")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        TextInput({ placeholder: '请输入设备编号（6位数字）' })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.deviceNumber = value;
          })
          .width('90%')
          .height(40)
          .margin({ top: 80 })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.search'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('查询设备')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 100, bottom: 20 })
        .onClick(() => this.queryDevice())
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}