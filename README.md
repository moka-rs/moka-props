# Moka Props

Moka Props is a test tool to perform _stateful_ property-based testing on the [Moka][moka] cache.

It will randomly generate commands with arguments, run them against the cache implementations and verify the returned values. It is like a superset of QuickCheck, which will not only generate test data, but also generate test cases.


## Overview

This tool is still in an early stage of development and missing many test cases. But it will eventually generate  commands including the followings:

- Create a cache with various configurations.
- Insert an entry with controlled-random key and value.
- Get an existing or not-existing entry.
- Invalidate an existing or not-existing entry.
- Tick cache's internal expiration clock.
- Pause or resume cache's internal bookkeeping tasks.
- Swap write log entries in the internal queue to emulate race conditions in concurrent writes.
- Drop a cache.

This tool uses the following frameworks/libraries and programming languages:

- [PropEr][proper], a property-based testing framework written in Erlang programming language.
- [PropCheck][propcheck], an Elixir binding for PropEr.
- Elixir programming language, for writing properties.
- [Rustler][rustler], a library for writing Erlang Native Implemented Functions (NIFs) in safe Rust code.
- Rust programming language, for creating a dynamic-link library containing Moka and its wrapper functions.

[moka]: https://github.com/moka-rs/moka
[proper]: https://github.com/proper-testing/proper
[propcheck]: https://hex.pm/packages/propcheck
[rustler]: https://crates.io/crates/rustler


## Why property-based testing?

Property-based testing helps us create better, more solid tests with little code. It will complement unit test based testing.


## Prerequisites

You need a machine running macOS or Linux.

You also need to install the following tools before building this tool:

- [ASDF version manager][asdf], for managing Erlang and Elixir toolchain and runtime environments.
- [Rustup], for managing Rust toolchain.

[asdf]: https://asdf-vm.com/
[rustup]: https://rustup.rs/


## Testing the properties (Running tests)

Clone this repository:

```console
$ git clone https://github.com/moka-rs/moka-props.git
$ cd moka-props
```

Get the dependencies for Elixir:

```console
$ mix deps.get
```

Build and run the tests:

```console
$ mix test
```


## Developing properties

To learn about PropEr, we would recommend the following book:

- [Property-Based Testing with PropEr, Erlang and Elixir][proper-book]
    - Author: Fred Hebert
    - Publisher: The Pragmatic Programmers, LLC.

[proper-book]: https://pragprog.com/titles/fhproper/property-based-testing-with-proper-erlang-and-elixir/


## License

**TODO**: Write this section and add the license file(s).

- Moka Props itself might be distributed under either of the MIT license or the Apache-2.0 license.
- Be aware that PropEr and PropCheck are distributed under the GPL-3.0 license.
    - You might want to run Moka Props, which links to PropEr and PropCheck, only in your development and testing environment.
    - You might want to avoid linking your final product to PropEr and PropCheck.
