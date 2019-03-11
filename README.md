# apxr_io

API server and website

--------------------
### Requirements

  - [asdf](https://asdf-vm.com/#/)
  - [Erlang/OTP 21](https://github.com/erlang)
  - [Elixir](https://elixir-lang.org/)
  - [PostgreSQL](https://www.postgresql.org/)
  - [Yarn](https://yarnpkg.com/)

--------------------
### Quick start

1. Run `mix setup` to install dependencies, create and seed database etc
2. Run `mix test` (--cover)
3. Run `iex -S mix phx.server` and visit [http://localhost:400/](http://localhost:400/)

After this succeeds you should be good to go!

See [`setup` alias in mix.exs](./mix.exs) and the sections below for more
information or when you run into issues.

--------------------
### PostgreSQL modules & version

PostgreSQL version should be >= 9.4, as apxr_io uses the `jsonb` type, that is
available from PostgreSQL 9.4 onward.

apxr_io requires the PostgreSQL modules [pg_trgm](http://www.postgresql.org/docs/9.4/static/pgtrgm.html) and [pgcrypto](http://www.postgresql.org/docs/9.4/static/pgcrypto.html)
to be available.

This is located in the "postgresql-contrib" project, however the project name
can vary depending on your operating system. If the module is not installed the
ecto migrations will fail.

--------------------
### Database

By default, apxr_io connects to a localhost PostgreSQL database `apxr_io_dev`
using the username `postgres` with the password `postgres`.

Create the database and user 'postgres' if not already done:

```sql
CREATE USER postgres;
ALTER USER postgres PASSWORD 'postgres';
CREATE DATABASE apxr_io_dev;
GRANT ALL PRIVILEGES ON DATABASE apxr_io_dev TO postgres;
ALTER USER postgres WITH SUPERUSER;

-- if you also want to setup the test database
CREATE DATABASE apxr_io_test;
GRANT ALL PRIVILEGES ON DATABASE apxr_io_test TO postgres;
```

Now you are fine to run the ecto migrations:

```shell
mix ecto.migrate
```

--------------------
### Sample data

Using the following command you can seed your local apxr_io instance with some
sample data:

```shell
mix run priv/repo/seeds.exs
```

--------------------
### Node dependencies

For assets compilation we need to install Node dependencies:

```shell
cd assets && yarn install
```

If you don't have yarn installed, run `brew install yarn --without-node` (if you
use nvm or similar, you should exclude installing Node.js so that nvm’s version
of Node.js is used) or `cd assets && npm install` will work too.

--------------------
### Running apxr_io

Once the database is set up you can start apxr_io:

```shell
# with console
iex -S mix phx.server

# without console
mix phx.server
```

apxr_io will be available at [http://localhost:400/](http://localhost:400/)

emails will be available at [http://localhost:400/sent_emails](http://localhost:400/sent_emails)

NOTE: when using Google Chrome, open chrome://flags/#allow-insecure-localhost
to enable the use of self-signed certificates on `localhost`.

--------------------
### Debugging

At the top of your module, add the following line:

```
require IEx
```

Next, inside of your function, add the following line:

```
IEx.pry
```

--------------------
### Modifying objects via the terminal

For example:

```
t = Teams.get("bobs")
ApxrIo.Repo.update!(Ecto.Changeset.change(t, billing_active: true))
```

--------------------
### Static analysis scan

```
mix sobelow
```

--------------------
### Additional checks

1. Run `mix format`
2. Run `mix xref unreachable`
3. Run `mix credo`
4. Run `mix app.tree`
5. Run `mix hex.outdated`
6. Run `mix dialyzer` (release candidate)

or

1. Run `mix check`

which runs the following:

```
["deps.get", "hex.outdated", "compile", "format", "mix sobelow", "xref unreachable", "dialyzer", "test --cover"]
```

--------------------
### Monitoring (production safe)

```
iex(1)> :observer_cli.start
```

--------------------
### Proto

Files should be generated with the following library `https://github.com/tsloughter/grpcbox`.

--------------------
Copyright (C) 2018 - 2019 ApproximateReality - approximatereality@gmail.com