import { image } from "@kit.ImageKit";
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from "@kit.CoreFileKit"
import { http } from "@kit.NetworkKit";
import { photoAccessHelper } from "@kit.MediaLibraryKit";

class ImageUtils {
  /**
   * 从 Resource 或 rawfile 文件名加载图片并生成高DPI的 PixelMap
   * @param UIContext UI上下文
   * @param icon Resource 资源对象 (例如 $r('app.media.icon')) 或 rawfile 文件名 (例如 'icon.svg')
   * @returns Promise<image.PixelMap>
   */
  async getPixelImage(UIContext: UIContext, icon: Resource | string): Promise<image.PixelMap> {
    if (!UIContext) {
      throw new Error("#getPixelImage Context is not initialized.");
    }
    try {
      const context = UIContext.getHostContext()!
      const resourceMgr = context.resourceManager;
      let imageSource: image.ImageSource;

      if (typeof icon === 'string') {
        // 从 rawfile 加载
        console.info(`#getPixelImage Loading icon from rawfile: ${icon}`);
        const fileData = resourceMgr.getRawFileContentSync(icon);
        imageSource = image.createImageSource(fileData.buffer);
      } else {
        // 从 Resource 加载
        console.info(`#getPixelImage Loading icon from Resource: ${icon.id}`);
        const mediaData = await resourceMgr.getMediaContent(icon.id);
        // getMediaContent 返回 Uint8Array，需要通过 .buffer 属性获取 ArrayBuffer
        imageSource = image.createImageSource(mediaData.buffer);
      }

      // 创建高DPI的PixelMap
      // 定义状态栏图标的 vp 尺寸
      const vpSize = 24;
      // 将 vp 转换为当前屏幕的物理像素
      const targetSize = UIContext.vp2px(vpSize);
      // 创建解码选项，指定目标尺寸
      const decodingOptions: image.DecodingOptions = {
        desiredSize: {
          width: targetSize,
          height: targetSize
        }
      };
      // 使用创建高分辨率的 PixelMap
      console.info(`#getPixelImage Creating PixelMap with target size: ${targetSize} x ${targetSize}`);
      return await imageSource.createPixelMap(decodingOptions);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`#getPixelImage Failed to load pixel maCode: ${err.code}, Message:${err.message}`);
      throw new Error(err.message);
    }
  }

  /**
   * 从 Resource 或 rawfile 文件名加载图片并生成高DPI的 Uint8Array
   * @param UIContext UI上下文
   * @param icon Resource 资源对象 (例如 $r('app.media.icon')) 或 rawfile 文件名 (例如 'icon.svg')
   * @returns Promise<Uint8Array>
   */
  async getResUint8Array(UIContext: UIContext, icon: Resource | string): Promise<Uint8Array> {
    if (!UIContext) {
      throw new Error("#getResUint8Array Context is not initialized.");
    }
    try {
      const context = UIContext.getHostContext()!
      const resourceMgr = context.resourceManager;
      let imageData:  Uint8Array;

      if (typeof icon === 'string') {
        // 从 rawfile 加载
        console.info(`#getResUint8Array get Uint8Array from rawfile: ${icon}`);
        imageData = resourceMgr.getRawFileContentSync(icon);
      } else {
        // 从 Resource 加载
        console.info(`#getResUint8Array get Uint8Array from Resource: ${icon.id}`);
        imageData = await resourceMgr.getMediaContent(icon.id);
      }
      return imageData;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`#getResUint8Array Failed to get Uint8ArraCode: ${err.code}, Message:${err.message}`);
      throw new Error(err.message);
    }
  }

  /**
   * 选择自定义头图
   * 功能：从图库选择图片 -> 居中裁切 -> 缩放至 64x64 (高分辨率) -> 转换为 PNG 二进制数据
   * @returns Promise<Uint8Array | undefined> 返回处理后的图片字节数组，如果取消选择则返回 undefined
   */
  async selectCustomIcon(): Promise<Uint8Array | undefined> {
    // 配置选择器
    const PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.isEditSupported = true;
    PhotoSelectOptions.maxSelectNumber = 1;

    const photoPicker = new photoAccessHelper.PhotoViewPicker();
    // 选择图片
    const res = await photoPicker.select(PhotoSelectOptions);
    // 检查是否有选择结果
    if (!res || !res.photoUris || res.photoUris.length === 0) {
      return undefined;
    }
    const uri = res.photoUris[0];

    // 定义资源变量
    let file: fs.File | undefined = undefined;
    let imageSource: image.ImageSource | undefined = undefined;
    let pixelMap: image.PixelMap | undefined = undefined;
    let imagePacker: image.ImagePacker | undefined = undefined;

    try {
      // 打开文件
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      // 创建 ImageSource
      imageSource = image.createImageSource(file.fd);
      const imageInfo = await imageSource.getImageInfo();

      const originalWidth = imageInfo.size.width;
      const originalHeight = imageInfo.size.height;

      // 目标尺寸配置
      const targetSizeVp = 64;
      const pixelDensity = 3;
      const targetSizePx = targetSizeVp * pixelDensity;

      // 处理 PixelMap (裁切与缩放)
      // 直接创建 PixelMap，如果后续裁切失败，此对象也需在 finally 释放
      pixelMap = await imageSource.createPixelMap();
      // 判断是否需要缩放
      if (originalWidth > targetSizePx || originalHeight > targetSizePx) {
        const cropSize = Math.min(originalWidth, originalHeight);
        const cropX = Math.floor((originalWidth - cropSize) / 2);
        const cropY = Math.floor((originalHeight - cropSize) / 2);
        const cropRegion: image.Region = {
          x: cropX,
          y: cropY,
          size: {
            width: cropSize,
            height: cropSize
          }
        };
        // 裁切
        await pixelMap.crop(cropRegion);
        // 缩放
        await pixelMap.scale(targetSizePx / cropSize, targetSizePx / cropSize);
      }
      //  打包图片
      imagePacker = image.createImagePacker();
      const packOptions: image.PackingOption = {
        format: 'image/png',
        quality: 100
      };
      const packedData = await imagePacker.packing(pixelMap, packOptions);
      console.info(`Icon processed successfully: ${originalWidth}x${originalHeight} -> ${targetSizePx}x${targetSizePx}`);

      return new Uint8Array(packedData);
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Process image failed: Code ${error.code}, Message: ${error.message}`);
      // 抛出错误
      throw new Error("Process image failed: " + JSON.stringify(e));
    } finally {
      // 强制释放资源 (无论成功与否)
      // 释放顺序：Packer -> PixelMap -> Source -> File
      if (imagePacker) {
        imagePacker.release();
      }
      if (pixelMap) {
        pixelMap.release();
      }
      if (imageSource) {
        imageSource.release();
      }
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 选择图片（原图保存）
   * 功能：从图库选择图片 -> 直接保存原图到沙箱目录
   * @param context 应用上下文 (用于获取沙箱路径)
   * @param saveFileName 保存的文件名 (例如: 'custom_background.jpg')
   * @param sandboxPath 可选，自定义沙箱保存路径，不传则默认使用 context.filesDir
   * @returns Promise<string | undefined> 返回沙箱内的本地路径，失败或取消返回 undefined
   */
  async selectOriginalImage2Sand(context: Context, saveFileName: string, sandboxPath?: string): Promise<string | undefined> {
    // 配置选择器
    const PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    const photoPicker = new photoAccessHelper.PhotoViewPicker();
    try {
      // 选择图片
      const res = await photoPicker.select(PhotoSelectOptions);
      if (!res || !res.photoUris || res.photoUris.length === 0) {
        console.info('ImageUtils.selectOriginalImage2Sand: 用户取消选择');
        return undefined;
      }
      const srcUri = res.photoUris[0];
      // 打开源文件 (通过 URI)
      const srcFile = fs.openSync(srcUri, fs.OpenMode.READ_ONLY);
      // 定义目标路径：如果传入 sandboxPath 则使用，否则默认使用 filesDir
      const basePath = sandboxPath || context.filesDir;
      const destPath = `${basePath}/${saveFileName}`;
      // 创建目标文件
      const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      // 复制文件流 (高效拷贝)
      const bufferSize = 4096; // 4KB 缓冲区
      const buffer = new ArrayBuffer(bufferSize);
      let readLen = fs.readSync(srcFile.fd, buffer);
      while (readLen > 0) {
        fs.writeSync(destFile.fd, buffer, { length: readLen });
        readLen = fs.readSync(srcFile.fd, buffer);
      }
      // 关闭文件句柄
      fs.closeSync(srcFile);
      fs.closeSync(destFile);
      console.info(`ImageUtils.selectOriginalImage2Sand: 背景图已保存至 ${destPath}`);
      return destPath;

    } catch (error) {
      const err = error as BusinessError;
      console.error(`ImageUtils.selectOriginalImage2Sand: 保存背景图失败，Code: ${err.code}, Message:${err.message}`);
      return undefined;
    }
  }

/**
   * 将 Uint8Array 转换为 PixelMap
   * @param uint8Array Uint8Array 数组
   * @returns Promise<image.PixelMap>
   */
  uint8ArrayToPixelMap(uint8Array?: Uint8Array): image.PixelMap | undefined {
    // console.debug(`AccessControl ${JSON.stringify(uint8Array)}`)
    if (!uint8Array || uint8Array.length == 0) {
      return undefined
    }
    const imageSource = image.createImageSource(uint8Array.buffer.slice(0, uint8Array.buffer.byteLength))
    const pixelMap = imageSource.createPixelMapSync()
    imageSource.release()
    return pixelMap
  }

  /**
   * 从 URL 下载图片并转换为 Uint8Array
   * @param url 图片的在线 URL 地址
   * @returns Promise<Uint8Array | undefined> 图片的 Uint8Array 数据，失败返回 undefined
   */
  downloadImageAsUint8Array(url: string): Promise<Uint8Array | undefined> {
    return new Promise<Uint8Array | undefined>((resolve) => {
      if (!url) {
        resolve(undefined)
        return
      }

      let httpRequest = http.createHttp()
      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      }, (err: Error, data: http.HttpResponse) => {
        if (!err && data.result instanceof ArrayBuffer) {
          const uint8Array = new Uint8Array(data.result)
          console.info(`"ImageUtils.downloadImageAsUint8Array 图片下载成功: ${url}, 大小: ${uint8Array.length} bytes'`)
          resolve(uint8Array)
        } else {
          console.warn("ImageUtils.downloadImageAsUint8Array 图片下载失败: ", url)
          resolve(undefined)
        }
        httpRequest.destroy()
      })
    })
  }

}

export const Xb_ImageUtils = new ImageUtils()


