# Dmatrix

Docker matrix. Parallel execution of each possible combination defined in your
matrix file.

The matrix file can contain `build_arg` and `env` values which will be passed
to Docker during the image build and execution of your command.

Inspired by the [Travis Build Matrix](https://docs.travis-ci.com/user/build-matrix/).

## Example

### `.matrix.yaml`

```
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

```
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

Would use `dmatrix` to build & run `bundle exec rspec` in each combination your
matrix defines.

## Setup

```
# Gemfile

gem "dmatrix"
```

Create a `.matrix.yaml` file:

```
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

Run:

```
bundle exec dmatrix -- <your command>
```

If not command is specified the default Docker command should run.
