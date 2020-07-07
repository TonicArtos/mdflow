// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

enum LayoutMode { auto, narrow, wide }

extension MdFlowLayoutModeStringer on LayoutMode {
  String get text {
    switch (this) {
      case LayoutMode.auto:
        return 'Auto';
      case LayoutMode.narrow:
        return 'Narrow';
      case LayoutMode.wide:
        return 'Wide';
      default:
        throw UnknownLayoutModeException(this);
    }
  }
}

class UnknownLayoutModeException {
  UnknownLayoutModeException(Object v)
      : message = 'Unknown value: $v on LayoutMode';

  final String message;

  @override
  String toString() {
    if (message == null) return "Exception";
    return 'Exception: $message';
  }
}
