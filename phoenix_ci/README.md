# PhoenixCi

This project demonstrate how test Phoenix Framework with Dagger.

## Running test

Run `mix phx.integration_test`.

## Limitation

Currently, integration tests cannot be pass because of it try to connect
database to local network but Dagger didn't support that.
