
enum PageStatus {
  initial,
  loading,
  success,
  failure,
  loadMore,
  networkError,
  sessionExpire,
  webView,
}

extension PageStatusX on PageStatus {
  bool get isInitial        => this        == PageStatus.initial;
  bool get isLoading        => this        == PageStatus.loading;
  bool get isSuccess        => this        == PageStatus.success;
  bool get isFailure        => this        == PageStatus.failure;
  bool get isLoadMore       => this       == PageStatus.loadMore;
  bool get isNetworkError   => this   == PageStatus.networkError;
  bool get isSessionExpire  => this  == PageStatus.sessionExpire;
  bool get isWebView        => this       == PageStatus.webView;
}