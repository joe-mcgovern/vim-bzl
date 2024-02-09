# vim-bzl

A small vim plugin to provide helpers for working within a Bazel project. I built
this for myself and don't plan on extending it to a broader audience.

## Disclaimer

There are likely many bugs & inefficiencies in this package. I'm only concerned
with fixing issues that affect my daily workflow & usage of the tool.

## Pre-requisites

This plugin depends on [vim-dispatch](https://github.com/tpope/vim-dispatch) for
executing bazel commands. This must be installed for this package to work properly.

## Installation

Using vim's native package management:
```
mkdir -p ~/.vim/pack/plugin/start
git clone git@github.com:joe-mcgovern/vim-bzl.git ~/.vim/pack/plugin/start
```

## Integrations

### Go file integration

My primary use case for this is to kick off go tests that are defined as a
Bazel rule. 

The following commands are available to you when you have a `.go` file opened:

| Command | Default Mapping | Description |
| ------- | --------------- | ----------  |
| `:BazelTest`  | `<leader>bta` | Run `bzl test` on the nearest bazel package |
| `:BazelTestNearest` | `<leader>btn` | Run `bzl test` on the nearest bazel package, providing the nearest test under cursor as a `test_filter` |

### Bazel file integration

This plugin also provides some helpers for working with Bazel files.

The following commands are available to you when you are in a `.bazel` or `.bzl` file:

| Command | Default Mapping | Description |
| ------- | --------------- | ----------  |
| `:BazelTestCurrent`  | `<leader>bt` | Run `bzl test` on the bazel rule/macro under cursor |
| `:BazelBuildCurrent` | `<leader>bb` | Run `bzl build` on the bazel rule/macro under cursor |
| `:BazelRunCurrent` | `<leader>br` | Run `bzl run` on the bazel rule/macro under cursor |
