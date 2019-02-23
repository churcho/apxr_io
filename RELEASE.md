# Release process

(Original: https://www.cogini.com/blog/best-practices-for-deploying-elixir-apps)

--------------------
### Overview

We deploy Erlang "releases" using systemd for process supervision. We run in cloud or dedicated server instances running CentOS or Ubuntu Linux. We deploy using Ansible.

1. Set up the web server
2. Set up a build environment on the server
3. Check out code on the server from git and build a release
4. Deploy the release to the web server

The actual work of checking out and deploying is handled by simple shell scripts which you run on the build server or from your dev machine via ssh, e.g.:

```
# Check out latest code and build release on server
ssh -A deploy@build-server build/deploy-template/scripts/build-release.sh

# Deploy release
ssh -A deploy@build-server build/deploy-template/scripts/deploy-local.sh
```

--------------------
### Locking dependency versions

The process starts in your dev environment. When you run mix deps.get, mix fetches the dependencies listed in the mix.exs. Mix records the specific versions that it fetched in the mix.lock file. Later, on the build machine, mix uses the specific package version or git reference in the lock file to build the release.

--------------------
### Managing build tool versions

When building a release, Elixir is just another library dependency and we normally package the Erlang virtual machine with the release too.

In order to reliably upgrade and roll back systems, we need to be able to precisely specify Erlang and Elixir versions.

We use ASDF to manage the versions of Erlang, Elixir and Node.js. ASDF looks at the .tool-versions file and automatically sets the path to point to the specified version used by each project. Install ASDF as described here: https://github.com/cogini/elixir-deploy-template#set-up-asdf

--------------------
### Building and testing

We normally develop on macOS and deploy to Linux. Erlang does not rely much on the operating system, and mix manages library dependencies tightly, so we don't find it necessary to use Vagrant or Docker to isolate projects.

It is necessary, however, to build your release with an Erlang binary that matches your target system. We can't build the release on macOS and deploy to Linux.

We build on the same server that runs the app. Check out the code from git, build a release, then run it locally.

Like your dev machine, the build server runs ASDF. When you make a build, it uses the versions of Erlang and Elixir specified in the .tool-versions file.

--------------------
### Erlang releases

The most important part of the deployment process is using Erlang "releases". A release combines the Erlang VM, your application, and the libraries it depends on into a tarball, which you deploy as a unit.

The release has a script to start the app, launched and supervised by the OS init system (e.g. systemd). If it dies, the supervisor restarts it.

Releases also support one of Erlang's cool features, hot code updates. If you are not keeping state in GenServers, then they are easy. If not, you need to write an upgrade function, like a database migration but for your state. We follow the "immutable infrastructure" paradigm so this does not really concern us.

--------------------
### SSH

We use ssh keys to control access to servers instead of passwords. This is more secure and easier to automate.

Connect to the server:


```
ssh root@web-server
```

If it doesn't work, run ssh with -v flags to see what the problem is. You can add more verbosity, e.g. -vvvv if you need more detail.

```
ssh -vv root@web-server
```

You can get a remote console on your production app just like it was running under iex. Log into the host server using ssh and run, e.g.:

```
MIX_ENV=prod /opt/apxr/apxr_io/current/bin/apxr_io remote_console
````


--------------------
### Distillery

The Distillery library makes it easy to build releases.

You can build release by running:

```
MIX_ENV=prod mix release
```

This creates a tarball with everything you need to deploy in e.g.

```
_build/prod/rel/apxr_io/releases/0.1.0/apxr_io.tar.gz
```

--------------------
### Supervising your app

In the Erlang OTP framework, we use supervisors to start and stop processes, restarting them in case of problems. It's turtles all the way down: you need a supervisor to make sure your Erlang VM is running, restarting it if there is a problem.

We use systemd to superivse the Erlang VM.

Systemd handles all the things that "well behaved" daemons need to do. Instead of scripts, it has declarative config that handles standard situations. It sets up the environment, handles logging and controls permissions.

For security, following the principle of least privilege, we limit the app to only what it really needs to do its job. That way if the app is compromised, the attacker is limited in what they can do.

Following that philosophy, we use a separate OS user (e.g. deploy) to upload the release files from the user that the app runs under (e.g. apxr_io).

If you are running systemd, then it will capture early startup error messages. Systemd captures any messages sent to the console and puts them in the system journal. journald handles log rotation, and the app doesn't need permissions to write log files, which is a security win.

--------------------
### Deploying the code

We use a structure like Capistrano to manage the release files. We first create a base directory named for the organization and app, e.g. `/opt/apxr/apxr_io`. Under that we create a releases directory to hold the release files.

The actual deployment process works like this:

1. Create a new directory for the release with a timestamp

  `/opt/apxr/apxr_io/releases/20171114T072116`

2. Upload the new release tarball to the server and unpack it

3. Make a symlink from `/opt/apxr/apxr_io/current` to the new release dir

4. Restart the app using the systemd unit

--------------------
### Deploying locally

Since this is a simple app, we build on the same server.

There are mix tasks help you copy the release files to a standard location on the local machine.

```
MIX_ENV=prod mix deploy.local
```

They handle the process of creating the timestamped directory, finding and extracting the release tarball, extracting it to the target dir, and making the symlink.

--------------------
### Rolling back

If there is a problem with the release, then it's easy to roll back. Just update the current symlink to point to the previous working release, then restart.

This task automates the process of rolling back to last release:

```
MIX_ENV=prod mix deploy.local.rollback
```

--------------------
### Deploying with Ansible

We use Ansible to set up the system and to deploy the code. It's a lightweight general-purpose tool which is easy for both devs and ops to understand.

We split the deployment into two phases, setup and deploy. In the setup phase, we do the tasks that require elevated permissions, e.g. creating user accounts, creating app dirs, installing OS packages, and setting up the firewall.

In the deploy phase, we push the latest code to the server and restart it. The deploy doesn't require admin permissions, so it can run from a regular user, e.g. the build server.

The configuration variables defined in `inventory/group_vars/all` apply to all hosts in your project. They are overridden by vars in more specific groups like `inventory/group_vars/web-servers` or for individual hosts, e.g. `inventory/host_vars/web-server`.

Ansible uses ssh to connect to the server. These playbooks use ssh keys to control logins to server accounts, not passwords. The users Ansible role manages accounts.

The `inventory/group_vars/all/users.yml` file defines a global list of users and system admins.

The `inventory/group_vars/all/elixir-release.yml` file specifies the app settings:

The `inventory/group_vars/build-servers/vars.yml` file specifies the build settings.

It specifies the project's git repo, which the Ansible playbook will check out on the build server
--------------------
### Listening directly on port 80

Normally, in order to listen on a port less than 1024, an app needs to be running as root or have elevated capabilities. That's a security problem waiting to happen, though, so we run the app on a normal port, e.g. 4001, and redirect traffic from port 443 to 4001 in the firewall.
