///
//  Generated code. Do not modify.
//  source: convenient_test.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'convenient_test.pb.dart' as $0;
export 'convenient_test.pb.dart';

class ConvenientTestManagerClient extends $grpc.Client {
  static final _$resetManagerCache = $grpc.ClientMethod<$0.Empty, $0.Empty>('/ConvenientTestManager/ResetManagerCache',
      ($0.Empty value) => value.writeToBuffer(), ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$report = $grpc.ClientMethod<$0.ReportCollection, $0.Empty>(
      '/ConvenientTestManager/Report',
      ($0.ReportCollection value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$getWorkerMode = $grpc.ClientMethod<$0.Empty, $0.WorkerMode>('/ConvenientTestManager/GetWorkerMode',
      ($0.Empty value) => value.writeToBuffer(), ($core.List<$core.int> value) => $0.WorkerMode.fromBuffer(value));
  static final _$managerToWorkerActionStream = $grpc.ClientMethod<$0.Empty, $0.ManagerToWorkerAction>(
      '/ConvenientTestManager/ManagerToWorkerActionStream',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ManagerToWorkerAction.fromBuffer(value));

  ConvenientTestManagerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options, $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> resetManagerCache($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$resetManagerCache, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> report($0.ReportCollection request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$report, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkerMode> getWorkerMode($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getWorkerMode, request, options: options);
  }

  $grpc.ResponseStream<$0.ManagerToWorkerAction> managerToWorkerActionStream($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$managerToWorkerActionStream, $async.Stream.fromIterable([request]), options: options);
  }
}

abstract class ConvenientTestManagerServiceBase extends $grpc.Service {
  $core.String get $name => 'ConvenientTestManager';

  ConvenientTestManagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>('ResetManagerCache', resetManagerCache_Pre, false, false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value), ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReportCollection, $0.Empty>(
        'Report',
        report_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ReportCollection.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.WorkerMode>('GetWorkerMode', getWorkerMode_Pre, false, false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value), ($0.WorkerMode value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ManagerToWorkerAction>(
        'ManagerToWorkerActionStream',
        managerToWorkerActionStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ManagerToWorkerAction value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> resetManagerCache_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return resetManagerCache(call, await request);
  }

  $async.Future<$0.Empty> report_Pre($grpc.ServiceCall call, $async.Future<$0.ReportCollection> request) async {
    return report(call, await request);
  }

  $async.Future<$0.WorkerMode> getWorkerMode_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getWorkerMode(call, await request);
  }

  $async.Stream<$0.ManagerToWorkerAction> managerToWorkerActionStream_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* managerToWorkerActionStream(call, await request);
  }

  $async.Future<$0.Empty> resetManagerCache($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> report($grpc.ServiceCall call, $0.ReportCollection request);
  $async.Future<$0.WorkerMode> getWorkerMode($grpc.ServiceCall call, $0.Empty request);
  $async.Stream<$0.ManagerToWorkerAction> managerToWorkerActionStream($grpc.ServiceCall call, $0.Empty request);
}
