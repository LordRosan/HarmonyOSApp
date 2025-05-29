@Builder
export function DeviceQueryBuilder() {
  DeviceQuery()
}

@Component
struct DeviceQuery {
  @State pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {

        Text('设备查询')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.numberQuery'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('设备编号查询')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('50%')
        .height(40)
        .margin({ top: 100, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('DeviceNumberQuery', null)
        })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.qrcodeQuery'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('二维码查询')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('50%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('QRCodeQuery', null)
        })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}