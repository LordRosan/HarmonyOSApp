import { RouteParam } from '../db/Device'
import DeviceAPI from '../db/DeviceAPI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { image } from '@kit.ImageKit'
import { fileIo as fs } from '@kit.CoreFileKit'
import {
  MultiFormatReader,
  DecodeHintType,
  RGBLuminanceSource,
  HybridBinarizer,
  BinaryBitmap,
  BarcodeFormat
} from '@ohos/zxing'
import promptAction from '@ohos.promptAction'

@Builder
export function QRCodeQueryBuilder() {
  QRCodeQuery()
}

@Component
struct QRCodeQuery {
  @State pathStack: NavPathStack = new NavPathStack()
  @State selectedImage: image.PixelMap | null = null
  @State imageSource: image.ImageSource | null = null

  private async decodeQRCode(pixelMap: image.PixelMap): Promise<string> {
    const reader = new MultiFormatReader()
    const hints = new Map<DecodeHintType, Array<BarcodeFormat>>()
    hints.set(DecodeHintType.POSSIBLE_FORMATS, [BarcodeFormat.QR_CODE])

    try {
      const buffer = await this.getImageBuffer(pixelMap)
      const imageInfo = await pixelMap.getImageInfo()
      const luminanceSource = new RGBLuminanceSource(
        buffer,
        imageInfo.size.width,
        imageInfo.size.height
      )
      const binaryBitmap = new BinaryBitmap(new HybridBinarizer(luminanceSource))
      return reader.decode(binaryBitmap, hints).getText()
    } catch (err) {
      console.error('解码失败:', err)
      promptAction.showToast({ message: '解码失败' })
      throw new Error('解码失败')
    }
  }

  private async getImageBuffer(pixelMap: image.PixelMap): Promise<Int32Array> {
    try {
      const buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber())
      await pixelMap.readPixelsToBuffer(buffer)
      return new Int32Array(buffer)
    } catch (err) {
      console.error('读取图像数据失败:', err)
      promptAction.showToast({ message: '读取图像数据失败' })
      throw new Error('读取图像数据失败')
    }
  }

  private async selectAndPreviewImage() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)

      if (result.photoUris.length > 0) {
        await this.loadImagePreview(result.photoUris[0])
      }
    } catch (err) {
      promptAction.showToast({ message: '图片选择失败' })
      console.error('图片选择失败:', err)
    }
  }

  private async loadImagePreview(uri: string) {
    try {
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
      const stat = fs.statSync(file.fd)
      const buffer = new ArrayBuffer(stat.size)
      fs.readSync(file.fd, buffer)
      fs.closeSync(file)

      this.imageSource = image.createImageSource(buffer)
      this.selectedImage = await this.imageSource.createPixelMap()
    } catch (err) {
      promptAction.showToast({ message: '图片加载失败' })
      console.error('图片加载失败:', err)
    }
  }

  private async processQRCode() {
    if (!this.selectedImage) {
      promptAction.showToast({ message: '请选择二维码图片' })
      return
    }

    try {
      // 解码二维码
      const deviceNumber = await this.decodeQRCode(this.selectedImage)
      // 查询设备
      const device = await DeviceAPI.getDevice(deviceNumber)
      if (!device) {
        promptAction.showToast({ message: '未查询到对应设备' })
        return
      }
      // 跳转详情页
      const routeParam: RouteParam = { deviceData: JSON.stringify(device) }
      this.pathStack.pushPathByName('DeviceDetail', routeParam)
    } catch (err) {
      promptAction.showToast({ message: '处理二维码失败' })
      console.error('处理二维码失败:', err)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('二维码查询')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        if (this.selectedImage) {
          Image(this.selectedImage)
            .width('80%')
            .aspectRatio(1)
            .margin(20)
            .borderRadius(10)
            .overlay('二维码预览', {
              align: Alignment.Bottom,
              offset: { x: 0, y: 20 }
            })
        } else {
          Column() {
            Image($r('app.media.qrcodeQuery'))
              .width(120)
              .height(120)
            Text('未选择图片')
              .fontSize(13)
              .margin({ top: 10 })
          }
          .width('80%')
          .height('50%')
          .justifyContent(FlexAlign.Center)
        }

        Row() {
          Button({ stateEffect: true, type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.qrcodeQuery'))
                .width(20)
                .height(20)
                .margin({ left: 10 })
              Text('选择图片')
                .fontSize(20)
                .fontColor(Color.White)
                .margin({ left: 15, right: 10 })
            }.alignItems(VerticalAlign.Center)
          }
          .width('40%')
          .height(40)
          .margin({ top: 20, bottom: 20 })
          .onClick(() => this.selectAndPreviewImage())
          .margin({ right: 20 })

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
          .margin({ top: 20, bottom: 20 })
          .onClick(() => this.processQRCode())
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