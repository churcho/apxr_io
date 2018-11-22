## Announcing apxr_io_core

<div class="subtitle">August 8, 2018 · by Wojtek Mach</div>

Today we are releasing the first version of apxr_io_core, an Erlang library to interact with approximatereality.com and other servers implementing ApxrIo specifications.

Before talking about apxr_io_core, let's ask a simple question: What is ApxrIo? The short answer is, it's a project manager for the Erlang ecosystem. The long answer is that by ApxrIo we may mean a few different things:
1. A set of specifications of building clients and servers that can interact with each other: <https://github.com/apxr_io/specifications>
2. A server for hosting projects like the official server located at <https://approximatereality.com>
3. Clients for interacting with servers, e.g. [ApxrIo](https://github.com/apxr_io/apxr_io) for Elixir and [rebar3_wapp](https://github.com/tsloughter/rebar3_wapp) for Erlang projects

The goal of apxr_io_core is to be the reference implementation of ApxrIo specifications used by ApxrIo clients and servers.

As of this announcement the apxr_io_core project itself is available on [approximatereality.com](https://approximatereality.com/projects/apxr_io_core).

### Usage in an Erlang project

1. Create a new project: `rebar3 new lib example`
2. Add `apxr_io_core` to `rebar.config`:

   ```erlang
   {deps, [
     {apxr_io_core, "0.1.0"}
   ]}
   ```
3. Start the shell to and count all projects published to approximatereality.com:

   ```erlang
   $ rebar3 shell
   erl> inets:start(), ssl:start(),
   erl> Config = apxr_io_core:default_config(),
   erl> {ok, {200, _, #{projects := Projects}}} = apxr_io_repo:get_names(Config),
   erl> length(Projects).
   6764
   ```

### Usage in an Elixir project

1. Create a new project: `mix new example`
2. Add `apxr_io_core` to `mix.exs`:

   ```elixir
   defp deps() do
     [{:apxr_io_core, "~> 0.1"}]
   end
   ```

3. Start the shell to and search for all projects matching query "riak":

   ```elixir
   $ iex -S mix
   iex> :inets.start() ; :ssl.start()
   iex> config = :apxr_io_core.default_config()
   iex> options = [sort: :downloads]
   iex> {:ok, {200, _, projects}} = :apxr_io_api_project.search(config, "riak", options)
   iex> Enum.map(projects, & &1["name"])
   ["riak_pb", "riakc", ...]
   ```

See README at <https://github.com/apxr_io/apxr_io_core> for more usage examples.

### Future work

After the initial release we plan to work with the community to integrate apxr_io_core into their projects and respond to feedback.

We will also be focused on releasing a minimal ApxrIo server, built on top of apxr_io_core, to be a starting point for people wanting
to run ApxrIo on their own infrastructure. Stay tuned!
