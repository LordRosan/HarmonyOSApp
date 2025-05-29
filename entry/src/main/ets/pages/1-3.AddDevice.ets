import { Device, DeviceType, DeviceStatus } from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import promptAction from '@ohos.promptAction'

@Builder
export function AddDeviceBuilder() {
  AddDevice()
}

@Component
struct AddDevice {
  @State pathStack: NavPathStack = new NavPathStack()
  @State number: string = ''
  @State name: string = ''
  @State type: DeviceType = DeviceType.SMALL
  @State status: DeviceStatus = DeviceStatus.NORMAL
  @State numberValid: boolean = false

  private async checkDevice() {
    if (!this.number) {
      promptAction.showToast({ message: '请输入设备编号' })
      return
    }
    try {
      const exists = await DeviceAPI.deviceExists(this.number)
      this.numberValid = !exists
      promptAction.showToast({
        message: exists ? '设备已存在' : '编号可用'
      })
    } catch (err) {
      console.error('验证失败:', err)
    }
  }

  private async submitDevice() {
    if (!this.numberValid) {
      promptAction.showToast({ message: '请先验证设备编号' })
      return
    }

    if (!this.name) {
      promptAction.showToast({ message: '设备名称不能为空' })
      return
    }

    const newDevice = new Device(
      this.number,
      this.name,
      this.type,
      this.status
    )

    try {
      const success = await DeviceAPI.addDevice(newDevice)
      if (success) {
        promptAction.showToast({ message: '添加成功' })
      } else {
        promptAction.showToast({ message: '添加失败' })
      }
    } catch (err) {
      console.error('添加设备异常:', err)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('设备添加')
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
              this.numberValid = false
            })
            .margin({ right: 20 })
          Button('验证设备')
            .width('25%')
            .onClick(() => this.checkDevice())
        }
        .width('90%')
        .margin({ bottom: 20 })

        TextInput({ placeholder: '请输入设备名称', text: this.name })
          .fontSize(20)
          .width('90%')
          .onChange(value => this.name = value)
          .margin({ bottom: 20 })

        Text('设备类型')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Column() {
          Row() {
            Radio({ value: DeviceType.SMALL, group: 'typeGroup' })
              .checked(this.type === DeviceType.SMALL)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = DeviceType.SMALL
                }
              })
              .margin({ left: 10 })
            Text('小型设备')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: DeviceType.MEDIUM, group: 'typeGroup' })
              .checked(this.type === DeviceType.MEDIUM)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = DeviceType.MEDIUM
                }
              })
              .margin({ left: 10 })
            Text('中型设备')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: DeviceType.LARGE, group: 'typeGroup' })
              .checked(this.type === DeviceType.LARGE)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.type = DeviceType.LARGE
                }
              })
              .margin({ left: 10 })
            Text('大型设备')
              .margin({ right: 10 })
          }
        }
        .margin({ bottom: 20 })

        Text('设备状态')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 10 })
        Column() {
          Row() {
            Radio({ value: DeviceStatus.NORMAL, group: 'statusGroup' })
              .checked(this.status === DeviceStatus.NORMAL)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.status = DeviceStatus.NORMAL
                }
              })
              .margin({ left: 10 })
            Text('正常状态')
              .margin({ right: 10 })
          }

          Row() {
            Radio({ value: DeviceStatus.FAILURE, group: 'statusGroup' })
              .checked(this.status === DeviceStatus.FAILURE)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.status = DeviceStatus.FAILURE
                }
              })
              .margin({ left: 10 })
            Text('故障状态')
              .margin({ right: 10 })
          }
        }
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
            this.number = ''
            this.name = ''
            this.type = DeviceType.SMALL
            this.status = DeviceStatus.NORMAL
            this.numberValid = false
          })
          .margin({ right: 20 })

          Button({ stateEffect: true, type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.add'))
                .width(20)
                .height(20)
                .margin({ left: 10 })
              Text('添加')
                .fontSize(20)
                .fontColor(Color.White)
                .margin({ left: 15, right: 10 })
            }.alignItems(VerticalAlign.Center)
          }
          .width('30%')
          .height(40)
          .onClick(() => this.submitDevice())
          .margin({ left: 20 })
        }
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}