import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../wo_http.dart';

class WoDefaultHttpApiClient implements WoHttpClient {
  final String baseUrl;
  final http.Client _client;
  final List<WoHttpInterceptor> _interceptors;
  final Map<String, String> _defaultHeaders;
  final Duration requestTimeout;
  final WoHttpErrorAdapter _defaultErrorAdapter;

  WoDefaultHttpApiClient({
    required this.baseUrl,
    http.Client? client,
    List<WoHttpInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
    Duration? requestTimeout,
    WoHttpErrorAdapter? errorAdapter,
  })  : _client = client ?? http.Client(),
        _interceptors = interceptors ?? <WoHttpInterceptor>[],
        requestTimeout = requestTimeout ?? const Duration(seconds: 30),
        _defaultErrorAdapter =
            errorAdapter ?? const WoDefaultHttpErrorAdapter(),
        _defaultHeaders = defaultHeaders ??
            const <String, String>{
              'Connection': 'keep-alive',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            };

  @override
  Future<WoResult<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _requestRaw(
      WoHttpMethod.get,
      path,
      headers: headers,
    );

    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  @override
  Future<WoResult<T>> post<T>(
    String path, {
    data,
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _requestRaw(
      WoHttpMethod.post,
      path,
      data: data,
      headers: headers,
    );

    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  @override
  Future<WoResult<T>> put<T>(
    String path, {
    data,
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _requestRaw(
      WoHttpMethod.put,
      path,
      data: data,
      headers: headers,
    );

    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  @override
  Future<WoResult<T>> patch<T>(
    String path, {
    data,
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _requestRaw(
      WoHttpMethod.patch,
      path,
      data: data,
      headers: headers,
    );

    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  @override
  Future<WoResult<T>> delete<T>(
    String path, {
    data,
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _requestRaw(
      WoHttpMethod.delete,
      path,
      data: data,
      headers: headers,
    );

    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  @override
  Future<WoResult<T>> upload<T>(
    String path, {
    WoHttpMethod method = WoHttpMethod.post,
    String fileFieldName = 'files',
    Map<String, String>? fields,
    List<WoUploadFile>? files,
    Map<String, String>? headers,
    T Function(dynamic raw)? parser,
    WoHttpErrorAdapter? errorAdapter,
  }) async {
    final response = await _uploadRaw(
      path,
      method: method,
      fileFieldName: fileFieldName,
      fields: fields,
      files: files,
      headers: headers,
    );
    return WoResult.fromHttpResponse(
      response,
      parser: parser,
      errorAdapter: errorAdapter ?? _defaultErrorAdapter,
    );
  }

  Future<WoHttpResponse> _requestRaw(
    WoHttpMethod method,
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = <String, String>{
      ..._defaultHeaders,
      ...?headers,
    };

    final request = WoHttpRequest(
      method: method,
      path: path,
      uri: uri,
      headers: mergedHeaders,
      body: data,
    );

    return _execute(request);
  }

  Future<WoHttpResponse> _uploadRaw(
    String path, {
    WoHttpMethod method = WoHttpMethod.post,
    String fileFieldName = 'files',
    Map<String, String>? fields,
    List<WoUploadFile>? files,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = <String, String>{
      ..._defaultHeaders,
      ...?headers,
    };

    final request = WoHttpRequest(
      method: method,
      path: path,
      uri: uri,
      headers: mergedHeaders,
      formFields: fields,
      files: files,
      fileFieldName: fileFieldName,
    );

    return _execute(request);
  }

  Future<WoHttpResponse> _execute(WoHttpRequest initialRequest) async {
    WoHttpRequest request = initialRequest;
    for (final interceptor in _interceptors) {
      request = await interceptor.onRequest(request);
    }

    WoHttpResponse response = await _send(request);

    if (response.isSuccess) {
      for (final interceptor in _interceptors) {
        response = await interceptor.onResponse(response);
      }
      return response;
    }

    for (final interceptor in _interceptors) {
      response = await interceptor.onError(
        WoHttpErrorContext(
          request: request,
          response: response,
          retry: (retryRequest) => _execute(retryRequest),
        ),
      );
    }

    return response;
  }

  Future<WoHttpResponse> _send(WoHttpRequest request) async {
    try {
      if ((request.files ?? const <WoUploadFile>[]).isNotEmpty) {
        return _sendMultipart(request);
      }

      final baseRequest = http.Request(request.method.value, request.uri)
        ..headers.addAll(request.headers);

      if (request.body != null) {
        if (request.body is String) {
          baseRequest.body = request.body as String;
        } else {
          baseRequest.body = jsonEncode(request.body);
        }
      }

      final streamed = await _client.send(baseRequest).timeout(requestTimeout);
      final response = await http.Response.fromStream(streamed);

      return WoHttpResponse(
        statusCode: response.statusCode,
        body: _decodeResponseBody(response.body),
        headers: response.headers,
        request: request,
      );
    } on TimeoutException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {'message': 'Request timeout. Please try again.'},
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    } on SocketException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {
          'message': 'No Internet connection. Please check your connection.'
        },
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    } on http.ClientException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {'message': 'Network request failed. Please try again.'},
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    }
  }

  Future<WoHttpResponse> _sendMultipart(WoHttpRequest request) async {
    try {
      final multipart = http.MultipartRequest(request.method.value, request.uri)
        ..headers.addAll(request.headers);

      multipart.headers.remove('Content-Type');

      if (request.formFields != null) {
        multipart.fields.addAll(request.formFields!);
      }

      final files = request.files ?? <WoUploadFile>[];
      for (final file in files) {
        final contentType = file.contentType != null
            ? MediaType.parse(file.contentType!)
            : null;

        if (file.bytes != null && file.bytes!.isNotEmpty) {
          multipart.files.add(http.MultipartFile.fromBytes(
            request.fileFieldName,
            file.bytes!,
            filename: file.filename,
            contentType: contentType,
          ));
          continue;
        }

        if (file.path != null && file.path!.isNotEmpty) {
          multipart.files.add(
            await http.MultipartFile.fromPath(
              request.fileFieldName,
              file.path!,
              filename: file.filename,
              contentType: contentType,
            ),
          );
        }
      }

      final streamed = await _client.send(multipart).timeout(requestTimeout);
      final response = await http.Response.fromStream(streamed);

      return WoHttpResponse(
        statusCode: response.statusCode,
        body: _decodeResponseBody(response.body),
        headers: response.headers,
        request: request,
      );
    } on TimeoutException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {'message': 'Request timeout. Please try again.'},
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    } on SocketException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {
          'message': 'No Internet connection. Please check your connection.'
        },
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    } on http.ClientException catch (e) {
      return WoHttpResponse(
        statusCode: 0,
        body: const {'message': 'Network request failed. Please try again.'},
        headers: const <String, String>{},
        request: request,
        exception: e,
      );
    }
  }

  dynamic _decodeResponseBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  @override
  void close() {
    _client.close();
  }
}
