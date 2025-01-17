# bundler

The bundler plugin installs ruby gem dependencies using bundler. This is required for deploying Rails apps. It also provides conveniences for using `bundle exec`.

## Settings

| Name                    | Purpose                                                                                                                                                                       | Default                   |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `bundler_install_flags` | Array of command-line flags to pass to the `bundle install` command                                                                                                           | `["--deployment"]`        |
| `bundler_gemfile`       | Optionally used to override the location of the Gemfile                                                                                                                       | `nil`                     |
| `bundler_jobs`          | Amount of concurrency used when downloading/installing gems                                                                                                                   | `"4"`                     |
| `bundler_path`          | Directory where gems where be installed                                                                                                                                       | `"%<shared_path>/bundle"` |
| `bundler_version`       | The version of bundler to install, used by the [bundler:upgrade_bundler](#bundlerupgrade_bundler) task; if `nil` (the default), determine the version based on `Gemfile.lock` | `nil`                     |
| `bundler_without`       | Array of Gemfile groups to exclude from installation                                                                                                                          | `["development", "test"]` |

## Tasks

### bundler:upgrade_bundler

Installs the version of bundler specified by the `:bundler_version` setting, if specified. If `:bundler_version` is `nil` (the default), this task will automatically determine the version of bundler required by the app that is being deployed by looking at the `BUNDLED WITH` entry within the app’s `Gemfile.lock`. If `:bundler_version` is `nil` and the app is missing a lockfile, then this task does nothing. Bundler will be installed withing this command:

```
gem install bundler --conservative --no-document -v VERSION
```

`bundler:upgrade_bundler` is intended for use as a [setup](../commands/setup.md) task. It should be run prior to [bundler:install](#bundlerinstall) to ensure that the correct version bundler is present.

### bundler:install

Runs `bundle install` to download and install all the dependencies specified by the Gemfile of the app that is being deployed. As a performance optimization, this task will run `bundle check` first to see if the app’s dependencies have already been installed. If so, `bundle install` is skipped.

`bundler:install` is intended for use as a [deploy](../commands/deploy.md) task. It should be run prior to any tasks that rely on gems.

### bundler:clean

Runs `bundle clean` to delete any previously installed gems that are no longer needed by the current version of the app. Cleaning is generally good practice to save disk space and speed up app launch time.

`bundler:clean` is intended for use as a [deploy](../commands/deploy.md) task. It should be run at the conclusion of the deploy after all other tasks.

## Helpers

These helper methods become available on instances of [Remote](../api/Remote.md) when the bundler plugin is loaded. They accept the same `options` as [Remote#run](../api/Remote.md#run42command-4242options-tomoresult).

### remote.bundle(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `bundle` within `release_path` by default.

```ruby
remote.bundle("exec", "rails", "console")
# $ cd /var/www/my-app/current && bundle exec rails console
```

### remote.bundle?(\*args, \*\*options) → true or false

Same as `bundle` but returns `true` if the command succeeded, `false` otherwise.
