# Makefile usage of OpenWCH for ch32v30x

This repository provides a Makefile scripts to build and work with openwch code for ch32v30x.

## Clone and build

This repository uses a fork of openwch/ch32v307 repository. You need to clone with `--recurse-submodules` or init/update with corresponding `git submodule init` and `git submodule update`.

```sh
git clone --recurse-submodules git@github.com:martinribelotta/openwch-makefile.git
```

By default the makefile configuration build the example in `EVT/EXAM/ADC/Internal_Temperature`. For change this edit Makefile and change the `EXAMPLE` variable or (preferred), indicate this value in the command line like this:

```sh
make EXAMPLE=EVT/EXAM/ADC/TIM_Trigger
```

The supported working examples can see in [test/TESTS.txt](test/TESTS.txt) file.

For verbose build, set the variable `VERBOSE` to `y` in command line or `Makefile` project
