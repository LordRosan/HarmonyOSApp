@Builder
export function AboutBuilder() {
  About()
}

@Component
struct About {
  //
  @State pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        // 页面标题
        Text('关于')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        // 应用信息展示
        Text('应用名称: 基于鸿蒙的远程设备核验程序')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Text('版本: 1.0.0')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Text('开发者: 周默予')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Text('联系方式: ')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}