@Component
struct Title {
 @State title: string = ''
  build() {
    Text(this.title)
      .fontSize(24)
  }
}
export default Title