# Playing with refactoring

An exercise in refactoring some very old code/tests used to format date ranges. The goal was to bring the code into line with modern standards and coding practices.

## Requirements

  - ruby 2.4+
  - docker (optional)

## How to build the environment?

If you don't have a local development environment, you can easily create it using docker. The following commands will bring up the environment and open the shell:

  ```
  docker build --tag refactor-test .
  docker run -it refactor-test
  ```

All tests will be executed as part of the build, and the coverage report will be generated in `./coverage/index.html`. If need be, you can re-run the tests manually with:

  ```
  docker$ bundle exec rubocop
  docker$ bundle exec rspec
  ```

## How to run the tests locally?

If your environment is already setup for local development, then all the tests can be run locally without requiring the use of docker.

Required gems can be installed with:

  - `bundle install`

Tests are run using:

  - `bundle exec rubocop`
  - `bundle exec rspec`

After running `rspec`, coverage report is available in `./coverage/index.html`.
