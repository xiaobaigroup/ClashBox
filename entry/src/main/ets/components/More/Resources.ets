@Component
struct Resources {
  @Consume('NavPathStack') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Text('Resources页')
    }
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}

export default Resources