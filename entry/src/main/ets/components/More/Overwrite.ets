@Component
struct Overwrite {

  @Consume('NavPathStack') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Text('Overwrite页')
    }
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}
export default Overwrite