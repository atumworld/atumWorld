# OD data protobuf example

All of this is a prototype/sketch.

First install the protonbuf compiler. On Ubuntu, `sudo apt-get install
protobuf-compiler`; on other platforms, see
<https://developers.google.com/protocol-buffers/docs/downloads>.

Then generate the Python library as follows:

```
protoc od.proto --python_out=.
```

This creates `od_pb2.py`.

Then run the Python script: `./python_example.py`
