// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('node')
import 'dart:async';
import 'dart:js';

import 'package:js/js.dart';
import 'package:node_interop/bindings.dart';
import 'package:node_interop/http.dart';
import 'package:test/test.dart';

final HTTP nodeHTTP = require('http');

void main() {
  group('HTTP client', () {
    Server server;

    setUpAll(() {
      server = nodeHTTP.createServer(allowInterop((IncomingMessage req, ServerResponse res) {
        res.setHeader('Content-Type', 'text/plain');
        res.setHeader('X-Foo', 'bar');
        res.writeHead(200, 'Ok');
        res.end('ok');
      }));
      var completer = new Completer();
      server.listen(8181, allowInterop(() {
        completer.complete();
      }));
      return completer.future;
    });

    tearDownAll(() {
      var completer = new Completer();
      server.close(allowInterop(() {
        completer.complete();
      }));
      return completer.future;
    });

    test('make request', () async {
      var client = new NodeClient();
      var response = await client.get('http://localhost:8181/test');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, 'ok');
      client.close();
    });
  });
}
