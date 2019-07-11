# Dmatrix

Docker matrix. Parallel execution of each possible combination defined in your
matrix file.

The matrix file can contain `build_arg` and `env` values which will be passed
to Docker during the image build and execution of your command.

Inspired by the [Travis Build Matrix](https://docs.travis-ci.com/user/build-matrix/).

## Example

### `.matrix.yaml`

```yaml
matrix:
  build_arg:
    FROM_IMAGE:
      - ruby:2.4-alpine
      - ruby:2.5-alpine
      - ruby:2.6-alpine
    BUNDLE_GEMFILE:
      - gemfiles/factory_bot_4_8.gemfile
      - gemfiles/factory_bot_5.gemfile
```

This would produce six combinations. In this example the `gemfiles` are created
with the [Appraisal gem](https://github.com/thoughtbot/appraisal).

### `Dockerfile`

```dockerfile
ARG FROM_IMAGE=ruby:2.6-alpine
FROM $FROM_IMAGE

RUN apk update && \
    apk add git && \
    mkdir -p /app/lib/my_gem

WORKDIR /app

COPY Gemfile* my_gem.gemspec Appraisals /app/
COPY gemfiles/*.gemfile /app/gemfiles/
COPY lib/my_gem/version.rb /app/lib/my_gem/version.rb

ARG BUNDLE_GEMFILE=Gemfile
ENV BUNDLE_GEMFILE=$BUNDLE_GEMFILE

RUN bundle install --jobs=4 --retry=3

COPY . /app
```

### Running a command

```
bundle exec dmatrix -- bundle exec rspec
```

This would use `dmatrix` to build & run `bundle exec rspec` for each combination
your matrix defines. In your terminal you should see output like this:

```
my_repo:ruby-2-4-alpine-gemfiles-factory_bot_4_8-gemfile   Build: success  Run: success
my_repo:ruby-2-4-alpine-gemfiles-factory_bot_5-gemfile     Build: success  Run: success
my_repo:ruby-2-5-alpine-gemfiles-factory_bot_4_8-gemfile   Build: success  Run: success
my_repo:ruby-2-5-alpine-gemfiles-factory_bot_5-gemfile     Build: success  Run: success
my_repo:ruby-2-6-alpine-gemfiles-factory_bot_4_8-gemfile   Build: success  Run: success
my_repo:ruby-2-6-alpine-gemfiles-factory_bot_5-gemfile     Build: success  Run: success
```

A build-log and run-log is written per combination in `./tmp/dmatrix`:

```
build-dmatrix-ruby-2-4-alpine-gemfiles-factory_bot_4_8-gemfile.log
run-dmatrix-ruby-2-4-alpine-gemfiles-factory_bot_4_8-gemfile.log
# etc
```

## Setup

### Get the gem

```ruby
# Gemfile

gem "dmatrix"
```

### Create a matrix

Create a `.matrix.yaml` file:

```yaml
matrix:
  build_arg:
    ARG1:
      - abc
      - def
  env:
    ENV1:
      - 123
      - 456
```

N.B. the `build_arg` and `env` keys can both contain multiple variants.

### Adapt your Dockerfile

Wire-up the ARG and ENV variables as required.

### Run

```
bundle exec dmatrix -- <your command>
```

If no command is specified the default Docker command will run.
