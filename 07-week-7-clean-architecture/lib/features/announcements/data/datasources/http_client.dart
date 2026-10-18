import 'package:dio/dio.dart';

Dio buildHttpClient() => Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );