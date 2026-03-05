enum WoHttpMethod {
  get,
  post,
  put,
  patch,
  delete,
}

extension WoHttpMethodValue on WoHttpMethod {
  String get value {
    switch (this) {
      case WoHttpMethod.get:
        return 'GET';
      case WoHttpMethod.post:
        return 'POST';
      case WoHttpMethod.put:
        return 'PUT';
      case WoHttpMethod.patch:
        return 'PATCH';
      case WoHttpMethod.delete:
        return 'DELETE';
    }
  }
}
