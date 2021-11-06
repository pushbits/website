# Getting Started

## Installation

PushBits is meant to be self-hosted.
That means you have to install it on your own server.
You are advised to install PushBits behind a reverse proxy and enable TLS.

Currently, the only supported way of installing PushBits is via [Docker](https://www.docker.com/) or [Podman](https://podman.io/).
The image is hosted [via ghcr.io](https://github.com/pushbits/server/pkgs/container/server).

## Configuration

To see what can be configured, have a look at the [config.sample.yml](https://github.com/pushbits/server/blob/master/config.example.yml) file inside the root of the repository.

Settings can optionally be provided via environment variables.
The name of the environment variable is composed of a starting `PUSHBITS_`, followed by the keys of the setting, all
joined with `_`.
As an example, the HTTP port can be provided as an environment variable called `PUSHBITS_HTTP_PORT`.

To get started, here is a Docker Compose file you can use.
```yaml
version: '2'

services:
    server:
        image: ghcr.io/pushbits/server:latest
        ports:
            - 8080:8080
        environment:
            PUSHBITS_DATABASE_DIALECT: 'sqlite3'
            PUSHBITS_ADMIN_MATRIXID: '@your/matrix/username:matrix.org' # The Matrix account on which the admin will receive their notifications.
            PUSHBITS_ADMIN_PASSWORD: 'your/pushbits/password' # The login password of the admin account. Default username is 'admin'.
            PUSHBITS_MATRIX_USERNAME: 'your/matrix/username' # The Matrix account from which notifications are sent to all users.
            PUSHBITS_MATRIX_PASSWORD: 'your/matrix/password' # The password of the above account.
        volumes:
            - /etc/localtime:/etc/localtime:ro
            - /etc/timezone:/etc/timezone:ro
            - ./data:/data
```

In this example, the configuration file would be located at `./data/config.yml` on the host.
The SQLite database would be written to `./data/pushbits.db`.
**Don't forget to adjust the permissions** of the `./data` directory, otherwise PushBits will fail to operate.

## Usage

We provide [a little CLI tool called pbcli](https://github.com/PushBits/cli) to make basic API requests to the server.
It helps you to create new users and applications.
You will find further instructions in the linked repository.

At the time of writing, there is no fancy GUI built-in, and we're not sure if this is necessary at all.
Currently, we would like to avoid front end development, so if you want to contribute in this regard we're happy if you reach out!

After you have created a user and an application, you can use the API to send a push notification to your Matrix account.

```bash
curl \
	--header "Content-Type: application/json" \
	--request POST \
	--data '{"message":"my message","title":"my title"}' \
	"https://pushbits.example.com/message?token=$PB_TOKEN"
```

Note that the token is associated with your application and has to be kept secret.
You can retrieve the token using [pbcli](https://github.com/PushBits/cli) by running following command.

```bash
pbcli application show $PB_APPLICATION --url https://pushbits.example.com --username $PB_USERNAME
```

### Message options

Messages can be specified in three different syntaxes:

* `text/plain`
* `text/html`
* `text/markdown`

To set a specific syntax you need to set the `extras` parameter ([inspired by Gotify's message extras](https://gotify.net/docs/msgextras#clientdisplay)):

```bash
curl \
	--header "Content-Type: application/json" \
	--request POST \
	--data '{"message":"my message with\n\n**Markdown** _support_.","title":"my title","extras":{"client::display":{"contentType": "text/markdown"}}}' \
	"https://pushbits.example.com/message?token=$PB_TOKEN"
```

HTML content might not be fully rendered in your Matrix client; see the corresponding [Matrix specs](https://spec.matrix.org/unstable/client-server-api/#mroommessage-msgtypes).
This also holds for Markdown, as it is translated into the corresponding HTML syntax.

### Deleting a Message

You can delete a message, this will send a notification in response to the original message informing you that the message is "deleted".

To delete a message, you need its message ID  which is provided as part of the response when you send the message.
The ID might contain characters not valid in URIs.
We hence provide an additional `id_url_encoded` field for messages; you can directly use it when deleting a message without performing encoding yourself.

```bash
curl \
	--request DELETE \
	"https://pushbits.example.com/message/${MESSAGE_ID}?token=$PB_TOKEN"
```
