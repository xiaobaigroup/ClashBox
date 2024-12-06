@Component
struct RequestPage {
  @Consume('NavPathStack') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Text('Request页')
    }
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}

export default RequestPage