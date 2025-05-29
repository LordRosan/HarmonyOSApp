@Entry
@Component
struct MainPage {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text('基于鸿蒙的远程设备核验程序')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 50 })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.search'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('设备查询')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 100, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('DeviceQuery', null)
        })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.report'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('报告提交')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('ReportSubmission', null)
        })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.add'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('设备添加')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('AddDevice', null)
        })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.delete'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('设备删除')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('DeleteDevice', null)
        })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.about'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('关于程序')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 100, bottom: 20 })
        .onClick(() => {
          this.pathStack.pushPathByName('About', null)
        })
      }
      .alignSelf(ItemAlign.Center)
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
  }
}
