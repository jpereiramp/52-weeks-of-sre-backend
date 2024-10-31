# 52 Weeks of SRE - Backend Server

Welcome to the backend server repository for the [52 Weeks of SRE](https://jpereira.me/tag/52-weeks-of-sre/) blog series! In this repository we'll work on building a production-ready REST API server that we'll use to demonstrate Site Reliability Engineering (SRE) concepts and practices throughout the series.

## About This Repository

This server is built on top of the excellent [go-base](https://github.com/dhax/go-base) template, which provides a solid foundation for building RESTful APIs in Go. We've chosen this template for its well-structured codebase and comprehensive feature set, making it an ideal starting point for exploring SRE practices in a real-world context.

Throughout the "52 Weeks of SRE" series, we'll be:
- Implementing monitoring and observability
- Setting up CI/CD pipelines
- Configuring automated testing
- Implementing infrastructure as code
- And much more!

Stay tuned to the blog series to follow along with our SRE journey.

---

## Original Template Documentation

The following documentation is extracted from the original `go-base` template:

### Features

The following feature set is a minimal selection of typical Web API requirements:

- Configuration using [viper](https://github.com/spf13/viper)
- CLI features using [cobra](https://github.com/spf13/cobra)
- PostgreSQL support including migrations using [bun](https://github.com/uptrace/bun)
- Structured logging with [Logrus](https://github.com/sirupsen/logrus)
- Routing with [chi router](https://github.com/go-chi/chi) and middleware
- JWT Authentication using [lestrrat-go/jwx](https://github.com/lestrrat-go/jwx) with example passwordless email authentication
- Request data validation using [ozzo-validation](https://github.com/go-ozzo/ozzo-validation)
- HTML emails with [go-mail](https://github.com/go-mail/mail)

### Start Application

- Clone and change into this repository

#### Local

- Create a postgres database and set environment variables for your database accordingly if not using below defaults
- Run the application to see available commands: `go run main.go`
- Run all migrations from database/migrate folder: `go run main.go migrate`
- Run the application with command _serve_: `go run main.go serve`

#### Using Docker Compose

- First start the database only: `docker compose up -d postgres`
- Once initialize the database by running all migrations in database/migrate folder: `docker compose run server ./main migrate`
- Start the api server: `docker compose up`

### API Routes

#### Authentication

For passwordless login following routes are available:

| Path          | Method | Required JSON | Header                                | Description                                                             |
| ------------- | ------ | ------------- | ------------------------------------- | ----------------------------------------------------------------------- |
| /auth/login   | POST   | email         |                                       | the email you want to login with (see below)                            |
| /auth/token   | POST   | token         |                                       | the token you received via email (or printed to stdout if smtp not set) |
| /auth/refresh | POST   |               | Authorization: "Bearer refresh_token" | refresh JWTs                                                            |
| /auth/logout  | POST   |               | Authorizaiton: "Bearer refresh_token" | logout from this device                                                 |

#### Example API

Besides /auth/ the API provides two main routes /api/* and /admin/*, as an example to separate application and administration context. The latter requires to be logged in as administrator by providing the respective JWT in Authorization Header.

#### Client API Access and CORS

The server is configured to serve a Progressive Web App (PWA) client from _./public_ folder (this repo only serves an example index.html). In this case enabling CORS is not required, because the client is served from the same host as the api.

If you want to access the api from a client that is served from a different host, you must enable CORS on the server first by setting environment variable _ENABLE_CORS=true_ on the server to allow api connections from clients served by other hosts.

#### Demo Users

Use one of the following bootstrapped users for login:

- <admin@example.com> (has access to admin panel)
- <user@example.com>

### Testing

Package auth/pwdless contains example api tests using a mocked database. Run them with: `go test -v ./...`

### Environment Variables

By default viper will look at ./dev.env for a config file. Setting your config as Environment Variables is recommended as by 12-Factor App.

| Name                    | Type          | Default                     | Description                                                                                                                                                                                               |
|-------------------------| ------------- | --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PORT                    | string        | localhost:3000              | http address (accepts also port number only for heroku compability)                                                                                                                                       |
| LOG_LEVEL               | string        | debug                       | log level                                                                                                                                                                                                 |
| LOG_TEXTLOGGING         | bool          | false                       | defaults to json logging                                                                                                                                                                                  |
| DB_DSN                  | string        | postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable              | database dsn connection string                                                                                                                                                                       |
| AUTH_LOGIN_URL          | string        | http://localhost:3000/login | client login url as sent in login token email                                                                                                                                                             |
| AUTH_LOGIN_TOKEN_LENGTH | int           | 8                           | length of login token                                                                                                                                                                                     |
| AUTH_LOGIN_TOKEN_EXPIRY | time.Duration | 11m                         | login token expiry                                                                                                                                                                                        |
| AUTH_JWT_SECRET         | string        | random                      | jwt sign and verify key - value "random" creates random 32 char secret at startup (and automatically invalidates existing tokens on app restarts, so during dev you might want to set a fixed value here) |
| AUTH_JWT_EXPIRY         | time.Duration | 15m                         | jwt access token expiry                                                                                                                                                                                   |
| AUTH_JWT_REFRESH_EXPIRY | time.Duration | 1h                          | jwt refresh token expiry                                                                                                                                                                                  |
| EMAIL_SMTP_HOST         | string        |                             | email smtp host (if set and connection can't be established then app exits)                                                                                                                               |
| EMAIL_SMTP_PORT         | int           |                             | email smtp port                                                                                                                                                                                           |
| EMAIL_SMTP_USER         | string        |                             | email smtp username                                                                                                                                                                                       |
| EMAIL_SMTP_PASSWORD     | string        |                             | email smtp password                                                                                                                                                                                       |
| EMAIL_FROM_ADDRESS      | string        |                             | from address used in sending emails                                                                                                                                                                       |
| EMAIL_FROM_NAME         | string        |                             | from name used in sending emails                                                                                                                                                                          |
| ENABLE_CORS             | bool          | false                       | enable CORS requests                                                                                                                                                                                      |

## Credits

This project is based on the [go-base](https://github.com/dhax/go-base) template by [dhax](https://github.com/dhax). We thank them for providing such a well-structured foundation for building Go web applications.

## Contributing

Contributions are welcome! Feel free to open issues for questions, suggestions, or bug reports. Pull requests are also appreciated.