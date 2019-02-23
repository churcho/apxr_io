# Release process

Sources:
  - https://www.cogini.com/blog/best-practices-for-deploying-elixir-apps
  - https://www.cogini.com/blog/deploying-your-phoenix-app-to-digital-ocean-for-beginners
  - https://github.com/cogini/elixir-deploy-template
  - https://github.com/konstruktoid/ansible-role-hardening
  - https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean

--------------------
### Quickstart

Once you have configured Ansible, set up the servers:

```
ansible-playbook -u root -v -l web-servers playbooks/setup-web.yml -D
ansible-playbook -u root -v -l web-servers playbooks/deploy-app.yml --skip-tags deploy -D
ansible-playbook -u root -v -l build-servers playbooks/setup-build.yml -D
```

Build and deploy the code:

```
# Check out latest code and build release on server
ssh -A deploy@build-server build/deploy-template/scripts/build-release.sh

# Deploy release
ssh -A deploy@build-server build/deploy-template/scripts/deploy-local.sh
```

--------------------
### Overview

We deploy Erlang "releases" using systemd for process supervision. We run in cloud or dedicated server instances running Ubuntu Linux (CentOS supported but not tested) equipped with a security focused systemd configuration. We deploy using a combination of Terraform (Handles deploying an actual server), Packer (Builds images of a configured server, but doesn't actually deploy it) and Ansible (Automates server configuration) on immutable infrastructure.

1. Set up the web server
2. Set up build server
3. Build the app
4. Deploy the release

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

We typically build on the same server that runs the app e.g. check out the code from git, build a release, then run it locally.

Like your dev machine, the build server runs ASDF. When you make a build, it uses the versions of Erlang and Elixir specified in the .tool-versions file.

--------------------
### Erlang releases

The most important part of the deployment process is using Erlang "releases". A release combines the Erlang VM, your application, and the libraries it depends on into a tarball, which you deploy as a unit.

The release has a script to start the app, launched and supervised by the OS init system (e.g. systemd). If it dies, the supervisor restarts it.

Releases also support one of Erlang's cool features, hot code updates. If you are not keeping state in GenServers, then they are easy. If not, you need to write an upgrade function, like a database migration but for your state. We follow the "immutable infrastructure" paradigm so this does not really concern us.

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

The `inventory/group_vars/build-servers/vars.yml` file specifies the build settings. It specifies the project's git repo, which the Ansible playbook will check out on the build server.

--------------------
### Listening directly on port 80

Normally, in order to listen on a port less than 1024, an app needs to be running as root or have elevated capabilities. That's a security problem waiting to happen, though, so we run the app on a normal port, e.g. 4001, and redirect traffic from port 443 to 4001 in the firewall.

--------------------
### 1. Set up web server

Run the following Ansible commands from the `pipeline/ansible` dir in the project.

Initial server setup:

```
ansible-playbook -u root -v -l web-servers playbooks/setup-web.yml -D
```

In this command, `web-servers` is the group of servers, but you could also specify a specific host like `web-server`.

The -u flag specifies which user account to use on the server. We have to use root to do the initial bootstrap, but you should generally use your own user account, assuming it has sudo. The -v flag controls verbosity, you can add more v's to get more debug info. The -D flag shows diffs of the changes Ansible makes on the server. If you add --check to the Ansible command, it will show you the changes it is planning to do, but doesn't actually run them. These scripts are safe to run in check mode, but may give an error during the play if required OS packages are not installed.

Set up the app (create dirs, etc.):

```
ansible-playbook -u root -v -l web-servers playbooks/deploy-app.yml --skip-tags deploy -D
```

At this point, the web server is set up, but we need to build and deploy the app code to it.

--------------------
### 2. Set up build server

This can be the same as the web server or a separate server.

Set up the server:

```
ansible-playbook -u root -v -l build-servers playbooks/setup-build.yml -D
```

This sets up the build environment, e.g. installing ASDF.

--------------------
### 3. Build the app

Log into the deploy user on the build machine:

```
ssh -A deploy@build-server
cd ~/build/deploy-template
```

The -A flag on the ssh command gives the session on the server access to your local ssh keys. If your local user can access a GitHub repo, then the server can do it, without having to put keys on the server. Similarly, if the prod server is set up to accept your ssh key, then you can push code from the build server using Ansible without the web server needing to trust the build server.

If you are using a CI server to build and deploy code, then it runs in the background. Create a deploy key in GitHub so it can access to your source and add the ssh key on the build server to the deploy user account on the web servers so the CI server can push releases.

Build the production release:

```
scripts/build-release.sh
```

Note: `asdf install` builds Erlang from source, so the first time it runs it can take a long time. If it fails due to a lost connection, delete /home/deploy/.asdf/installs/erlang/[version] and try again. You may want to run it under `tmux`.

--------------------
### 4. Deploy the release (local)

If you are building on the web-server, then you can use the custom mix tasks in lib/mix/tasks/deploy.ex to deploy locally.

In mix.exs, set deploy_dir to match Ansible, i.e. deploy_dir: `/opt/apxr/apxr_io`:

Deploy the release:

```
scripts/deploy-local.sh
```

The build is being done under the deploy user, who owns the files under `/opt/apxr/apxr_io` and has a special `/etc/sudoers.d` config which allows it to run the `/bin/systemctl restart apxr_io` command.

--------------------
### 4. Deploy the release (remote)

Install Ansible on the build machine

Run the script found under `pipeline/ansible/provision/setup.sh` (on your dev machine) to install Ansible on the build machine.

On the build server:

```
ssh -A deploy@build-server
cd ~/build/deploy-template/ansible
```

Add the servers in ansible/inventory/hosts to ~/.ssh/config:

```
Host web-server
    HostName 123.45.67.89
```

For projects with lots of servers, we normally maintain the list of servers in a ssh.config file in the repo. See ansible/ansible.cfg for config.

Deploy the app

On the build server:

```
scripts/deploy-remote.sh
```

That script runs:

```
ansible-playbook -u deploy -v -l web-servers playbooks/deploy-app.yml --tags deploy --extra-vars ansible_become=false -D
```

--------------------
### Verify it works

Have a look at the logs:

```
systemctl status apxr_io
journalctl -r -u apxr_io
```

You can get a console on the running app by logging in (via ssh) as the `apxr_io` user the app runs under and executing:

/opt/apxr/apxr_io/scripts/remote_console.sh

--------------------
### 4. Database

Whenever you change the db schema, you need to run migrations on the server.

After building the release, but before deploying the code, update the db to match the code:

```
scripts/db-migrate.sh
```

That script runs:

```
MIX_ENV=prod mix ecto.migrate
```



