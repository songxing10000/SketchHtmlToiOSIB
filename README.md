# SketchHtmlToiOSIB
***
转换文件来源
- [x] 本地文件
- [ ] 网络url,存储到本地
***
输出格式
- [x] sb格式
- [ ] xib格式
- [ ] 手码格式
***
sb功能列表
- [x] 读取页面个数，生成对应个数的控制器
- [ ] 载入图片资源
***
vc功能列表
- [x] 根据title生成控制器sb中的label
- [x] 加入view、label、imageView控件
- [ ] 使用原生nav，导航栏，未移除，所有子控件y上移调整
- [ ] 加入scrollView控件
- [ ] 自动识别控件重叠，转换为button控件
- [ ] 自动识别控件复用，转换为table控件
- [ ] 大控件遮住了小控件，调整控件层级功能
- [ ] 最后个子控件超出屏幕后，设置vc的simulated size 为freeform，并更新height
***
label功能列表
- [x] rect
- [x] bg alpha
- [x] text
- [x] textColor
- [x] fontSize
- [ ] 宽高自适应，目前有挤压理解，暂处理为给宽度增加额外长度。
***
view功能列表
- [x] rect
- [x] bgColor
- [x] bg alpha
- [ ] 嵌套子控件（目前Sketch全是平级，没有嵌套子控件）
***
imageView功能列表
- [x] rect
- [x] bg alpha

