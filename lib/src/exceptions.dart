// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

class UnknownLayoutModeException extends _UnknownEnumValueException {
  static const String _type = 'MdFlowLayoutMode';

  UnknownLayoutModeException(Object v) : super(v, _type);
}

class UnknownLayoutStyleException extends _UnknownEnumValueException {
  static const String _type = 'MdFlowLayoutStyle';

  UnknownLayoutStyleException(Object v) : super(v, _type);
}

class UnknownActionLevelException extends _UnknownEnumValueException {
  static const String _type = 'MdFlowActionLevel';

  UnknownActionLevelException(Object v) : super(v, _type);
}

abstract class _UnknownEnumValueException implements Exception {
  _UnknownEnumValueException(Object v, String type) : message = 'Unknown value for enum $type: $v';

  final String message;

  @override
  String toString() {
    if (message == null) return "Exception";
    return 'Exception: $message';
  }
}
