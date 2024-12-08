@Component
struct Connect {
  @Consume('NavPathStack') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Text('Connect页')
    }
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}
export default Connect