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

## Testing the Alertmanager interface

Setting up a local [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) instance is done quickly using Docker or Podman.
We first create the file `config.yml` that tells Alertmanger where to send alerts.
Don't forget to replace `<PB_TOKEN>` with your application's token.
```yaml
route:
  receiver: default

receivers:
  - name: default
    webhook_configs:
      - url: http://localhost:8080/alert?token=<PB_TOKEN> # Replace <PB_TOKEN> with your application's token.
```

We mount this file into a container running Alertmanager.
For convenience, let's use this Makefile:
```make
CONTAINER_NAME := alertmanager
IMAGE_NAME := quay.io/prometheus/alertmanager

.PHONY: up
up:
	podman run --name $(CONTAINER_NAME) --rm --network host -v $(PWD)/config.yml:/etc/alertmanager/alertmanager.yml:Z $(IMAGE_NAME)

.PHONY: down
down:
	podman container stop $(CONTAINER_NAME)

.PHONY: send
send:
	amtool alert add alertname=testmessage --annotation=title='My Title' --annotation=message='My Message'

.PHONY: setup
setup:
	go install github.com/prometheus/alertmanager/cmd/amtool@latest
```

So first you would install the client using `make setup`, followed by starting Alertmanager with `make up`.
When PushBits is running, a `make send` would create a new alert in Alertmanager, which is then passed to PushBits via the defined webhook.
