@Builder
export function ReportSubmissionBuilder() {
  ReportSubmission()
}

@Component
struct ReportSubmission {
  //
  @State pathStack: NavPathStack = new NavPathStack()

  build() {
    // 使用 NavDestination 作为页面的根容器
    NavDestination() {
      Column() {
        // 页面标题
        Text('报告提交')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        // 故障报告选项
        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.failure'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('故障报告')
              .fontSize(20)
              .fontColor(0xffffff)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 100, bottom: 20 })
        .onClick(() => {
          //
          this.pathStack.pushPathByName('FailureReport', null)
        })

        // 维修报告选项
        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.repair'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('维修报告')
              .fontSize(20)
              .fontColor(0xffffff)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          //
          this.pathStack.pushPathByName('RepairReport', null)
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