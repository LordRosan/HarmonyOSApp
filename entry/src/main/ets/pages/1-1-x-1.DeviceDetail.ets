import {
  Device,
  DeviceStatus,
  DeviceType,
  FailureRecord,
  RepairRecord,
  SelfCheckRecord,
  RouteParam
} from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function DeviceDetailBuilder() {
  DeviceDetail()
}

@Component
struct DeviceInfoCard {
  @Prop title: string
  @Prop content: string[]

  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      Scroll() {
        Column() {
          ForEach(this.content, (item: string) => {
            Text(item)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 10 })
          })
        }
      }
      .height(100)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 20 })
  }
}

@CustomDialog
struct EditDeviceDialog {
  controller: CustomDialogController
  @Prop device: Device
  @State tempDevice: Device = new Device(
    this.device.number,
    this.device.name,
    this.device.type,
    this.device.status,
    [...this.device.failureRecords],
    [...this.device.repairRecords]
  )

  build() {
    Column() {
      Text('设备信息修改')
        .fontSize(30)
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 20 })

      Text('设备编号：' + this.device.number + '（不可修改）')
        .fontSize(20)
        .width('90%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      TextInput({ placeholder: '当前设备名称：' + this.device.name })
        .height(40)
        .width('90%')
        .onChange((value: string) => {
          this.tempDevice.name = value
        })
        .margin({ bottom: 20 })

      Text('设备类型')
        .fontSize(20)
        .margin({ bottom: 10 })
      Row() {
        Radio({ value: DeviceType.SMALL, group: 'typeGroup' })
          .checked(this.tempDevice.type === DeviceType.SMALL)
          .onChange((checked: boolean) => {
            if (checked) {
              this.tempDevice.type = DeviceType.SMALL
            }
          })
          .margin({ left: 10 })
        Text('小型设备')
          .margin({ right: 10 })

        Radio({ value: DeviceType.MEDIUM, group: 'typeGroup' })
          .checked(this.tempDevice.type === DeviceType.MEDIUM)
          .onChange((checked: boolean) => {
            if (checked) {
              this.tempDevice.type = DeviceType.MEDIUM
            }
          })
          .margin({ left: 10 })
        Text('中型设备')
          .margin({ right: 10 })

        Radio({ value: DeviceType.LARGE, group: 'typeGroup' })
          .checked(this.tempDevice.type === DeviceType.LARGE)
          .onChange((checked: boolean) => {
            if (checked) {
              this.tempDevice.type = DeviceType.LARGE
            }
          })
          .margin({ left: 10 })
        Text('大型设备')
          .margin({ right: 10 })
      }
      .margin({ bottom: 20 })

      Text('设备状态')
        .fontSize(20)
        .margin({ bottom: 10 })
      Row() {
        Radio({ value: DeviceStatus.NORMAL, group: 'statusGroup' })
          .checked(this.tempDevice.status === DeviceStatus.NORMAL)
          .onChange((checked: boolean) => {
            if (checked) {
              this.tempDevice.status = DeviceStatus.NORMAL
            }
          })
          .margin({ left: 10 })
        Text('正常状态')
          .margin({ right: 10 })

        Radio({ value: DeviceStatus.FAILURE, group: 'statusGroup' })
          .checked(this.tempDevice.status === DeviceStatus.FAILURE)
          .onChange((checked: boolean) => {
            if (checked) {
              this.tempDevice.status = DeviceStatus.FAILURE
            }
          })
          .margin({ left: 10 })
        Text('故障状态')
          .margin({ right: 10 })
      }
      .margin({ bottom: 20 })

      Row() {
        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.cancel'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('取消')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('30%')
        .height(40)
        .onClick(() => this.controller.close())
        .margin({ right: 20 })

        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.confirm'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('保存')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('30%')
        .height(40)
        .onClick(async () => {
          const success = await DeviceAPI.updateDevice(this.tempDevice)
          if (success) {
            promptAction.showToast({ message: '保存成功' })
            this.controller.close()
            this.device = new Device(
              this.tempDevice.number,
              this.tempDevice.name,
              this.tempDevice.type,
              this.tempDevice.status,
              [...this.tempDevice.failureRecords],
              [...this.tempDevice.repairRecords]
            )
          } else {
            promptAction.showToast({ message: '保存失败' })
          }
        })
        .margin({ left: 20 })
      }
      .margin({ top: 20, bottom: 10 })
    }
    .width('100%')
  }
}


@Component
struct DeviceDetail {
  @State pathStack: NavPathStack = new NavPathStack()
  @State device: Device | null = null
  private editDialogController: CustomDialogController = new CustomDialogController({
    builder: EditDeviceDialog({ device: new Device('', '', DeviceType.SMALL, DeviceStatus.NORMAL) }),
    autoCancel: true
  })

  build() {
    NavDestination() {
      Column() {
        Text('设备详情')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 10 })

        if (this.device) {
          Column() {
            DeviceInfoCard({
              title: '基本信息', content: [
                `设备编号：${this.device.number}`,
                `设备名称：${this.device.name}`,
                `设备类型：${this.device.type}`,
                `设备状态：${this.device.status}`
              ]
            }).width('90%')

            if (this.device.failureRecords?.length > 0) {
              DeviceInfoCard({
                title: `故障记录（共${this.device.failureRecords.length}条）`,
                content: this.device.failureRecords.map((record: FailureRecord) => {
                  return `编号：${record.number}\n日期：${record.date}\n故障信息：${record.description}\n紧急程度：${record.emergency}\n操作员：${record.operator}\n`
                })
              }).width('90%')
            }

            if (this.device.repairRecords?.length > 0) {
              DeviceInfoCard({
                title: `维修记录（共${this.device.repairRecords.length}条）`,
                content: this.device.repairRecords.map((record: RepairRecord) => {
                  return `编号：${record.number}\n日期：${record.date}\n维修类型：${record.type}\n维修信息：${record.description}\n操作人：${record.operator}\n`
                })
              }).width('90%')
            }

            if (this.device.selfCheckRecords?.length > 0) {
              DeviceInfoCard({
                title: `自检记录（共${this.device.selfCheckRecords.length}条）`,
                content: this.device.selfCheckRecords.map((record: SelfCheckRecord) => {
                  return `编号：${record.number}\n日期：${record.date}\n通过与否：${record.passed}\n`
                })
              }).width('90%')
            }
          }
        } else {
          Text('暂无设备详情信息')
            .fontSize(20)
            .margin({ top: 50 })
        }
        Button({ stateEffect: true, type: ButtonType.Capsule }) {
          Row() {
            Image($r("app.media.infoModify"))
              .width(20)
              .height(20)
              .margin({ left: 10 })
            Text('信息修改')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ left: 15, right: 10 })
          }.alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .height(40)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          if (this.device) {
            this.editDialogController = new CustomDialogController({
              builder: EditDeviceDialog({ device: this.device }),
              autoCancel: true
            })
            this.editDialogController.open()
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as RouteParam
      if (params?.deviceData) {
        try {
          this.device = JSON.parse(params.deviceData) as Device
        } catch (err) {
          console.error('设备数据解析失败：', err)
        }
      }
      this.pathStack = context.pathStack
    })
  }
}
