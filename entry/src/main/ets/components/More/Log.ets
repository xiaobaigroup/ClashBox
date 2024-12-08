@Component
struct Log {
  @Consume('NavPathStack') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Text('Log页')
    }
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}
export default Log