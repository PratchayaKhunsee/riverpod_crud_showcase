import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// หน่วยข้อมูล CRUD
class CrudModel<T> {
  final T _data;

  CrudModel._create(this._data);

  T get data => _data;

  @override
  String toString() => _data.toString();

  /// สร้างใหม่โดยสามารถแทนที่ด้วยข้อมูล [data] ได้ ถ้าไม่ใส่ก็ใช้ข้อมูลอันเดิม
  CrudModel<T> copyWith([T? data]) => CrudModel._create(data ?? _data);
}

/// โมเดลหลักสำหรับจัดการข้อมูล CRUD
class CrudModelList<T> extends ChangeNotifier {
  List<CrudModel<T>> _models = [];

  /// เจะเป็น true เมื่อเริ่มต้นอ่านข้อมูลสำเร็จ
  bool _preloadDone = false;

  /// ป้องกันการเรียกใช้ [notifyListeners] หลังจากที่ [dispose] แล้ว
  bool _disposed = false;

  /// ตัวอ่านข้อมูลจาก [SharedPreferences]
  SharedPreferences? _pref;

  /// ล็อกป้องกันการตั้งค่า [_pref] ซ้ำ
  Completer<void>? _prefLock;

  /// ถ้าพร้อมแล้ว จะเป็น true
  bool get isReady => _preloadDone;

  CrudModelList() {
    _loadModels();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// เริ่มต้นโหลดข้อมูล
  void _loadModels() async {
    final pref = await _getPref();
    final data = pref.getString('crud_list');

    if (data != null) {
      final list = data.split(String.fromCharCode(0));
      for (final item in list) {
        _models.add(CrudModel._create(item as T));
      }
    }

    _preloadDone = true;
    if (!_disposed) notifyListeners();
  }

  /// ดึงตัวแปร [_pref]
  Future<SharedPreferences> _getPref() async {
    if (_prefLock?.isCompleted == false) await _prefLock?.future;

    final prevPrev = _pref;
    if (prevPrev != null) return prevPrev;

    final lock = _prefLock ??= Completer();
    final pref = _pref = await SharedPreferences.getInstance();
    lock.complete();
    return pref;
  }

  /// สร้าง
  Future<CrudSubmissionResponse> create(T data) async {
    final created = CrudModel._create(data);
    final text = created.toString();

    if (text.isEmpty) {
      throw CrudSubmissionErrorResponseException('Data is empty');
    } else if (text.length > 24) {
      throw CrudSubmissionErrorResponseException('Data can only be no more than 24 characters');
    } else if (RegExp('[^0-9A-Za-z ]').hasMatch(text)) {
      throw CrudSubmissionErrorResponseException('Data can only be A-Z, a-z, 0-9 and space.');
    }

    final pref = await _getPref();
    final list = [..._models, created];
    final success = await pref.setString('crud_list', list.join(String.fromCharCode(0)));

    if (!success) {
      return CrudSubmissionResponse(success: false, data: null);
    }

    _models = list;
    if (!_disposed) notifyListeners();
    return CrudSubmissionResponse(success: true, data: null);
  }

  /// อ่าน
  CrudModel<T> read(int index) => _models[index];

  /// แก้ไข
  Future<CrudSubmissionResponse> update(int index, T data) async {
    if (index >= 0 && index < _models.length && _models[index]._data != data) {
      final text = data.toString();

      if (text.isEmpty) {
        throw CrudSubmissionErrorResponseException('Data is empty');
      } else if (text.length > 24) {
        throw CrudSubmissionErrorResponseException('Data can only be no more than 24 characters');
      } else if (RegExp('[^0-9A-Za-z ]').hasMatch(text)) {
        throw CrudSubmissionErrorResponseException('Data can only be A-Z, a-z, 0-9 and space.');
      }

      final list = _models.toList()
        ..removeAt(index)
        ..insert(index, _models[index].copyWith(data));

      final pref = await _getPref();
      final success = await pref.setString('crud_list', list.join(String.fromCharCode(0)));

      if (!success) {
        return CrudSubmissionResponse(success: false, data: null);
      }

      _models = list;
      if (!_disposed) notifyListeners();
      return CrudSubmissionResponse(success: true, data: null);
    }

    throw RangeError('Out of range: $index');
  }

  /// ลบ
  Future<CrudSubmissionResponse> delete(int index) async {
    if (index >= 0 && index < _models.length) {
      final list = _models.toList()..removeAt(index);

      final pref = await _getPref();
      final success = await pref.setString('crud_list', list.join(String.fromCharCode(0)));
      if (!success) {
        return CrudSubmissionResponse(success: false, data: null);
      }

      _models = list;
      if (!_disposed) notifyListeners();
      return CrudSubmissionResponse(success: true, data: null);
    }

    throw RangeError('Out of range: $index');
  }

  int getLength() => _models.length;
}

/// ผลลัพธ์ที่สำเร็จในการ CRUD
class CrudSubmissionResponse<T> {
  final bool success;
  final T data;

  CrudSubmissionResponse({required this.success, required this.data});
}

/// ถ้าพบข้อผิดพลาดในการ CRUD จะโยน [Exception] อันนี้แทน
class CrudSubmissionErrorResponseException implements Exception {
  final String message;

  CrudSubmissionErrorResponseException([this.message = '']);
}
