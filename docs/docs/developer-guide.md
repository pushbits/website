# Developer Guide

_This site is under construction._

## Testing

Testing is essential for delivering good and reliable software.
PushBits uses Go's integrated test features.
Unfortunately, writing tests is quite time consuming and therefore not every feature and every line of code is automatically tested.
Feel free to help us improve our tests.

To run tests for a single (sub)module you can simply execute the following command in the module's folder.

```bash
go test
```

To get the testing coverage for a module use the `-cover` flag.

```bash
go test -cover
```

To execute a single test use the `-run` flag.

```bash
go test -run "TestApi_getUser"
```

Running tests for all PushBits module is done like this:

```bash
make test
```
