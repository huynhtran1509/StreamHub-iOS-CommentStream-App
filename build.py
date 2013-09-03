#!/usr/bin/env python2

import os
import subprocess
import tempfile
import ConfigParser


def DirectoryOfThisScript():
    return os.path.dirname(os.path.abspath(__file__))


def ParamArray(prefix, args):
    # given a list of tuples (parameters and their values), return
    # a flattened list generator of items with prefix string prepended
    # to the first element of each tuple
    return (arg for t in args for arg in [prefix + t[0], t[1]])


def FilterOut(key, args):
    # take a list of tuples as second argument and return a list
    # generator of tuples that has no tuples that have key as their
    # first element
    return (t for t in args if t[0] != key)


def main():
    # read config file
    section = 'xcodebuild'
    target_option = 'target'
    derivedDataPath_option = 'derivedDataPath'
    script_dir = DirectoryOfThisScript()

    config_path = os.path.join(script_dir, '.ycm_extra_conf.cfg')
    defaults = {'configuration': 'Debug', 'sdk': 'iphonesimulator'}
    config = ConfigParser.ConfigParser(defaults)
    config.optionxform = str  # do not convert to lower-case
    config.read(config_path)

    # create a temporary directory for derived data if one
    # is not set already:
    if (not config.has_option(section, derivedDataPath_option)):
        target = config.get(section, target_option)
        tmpdir = tempfile.mkdtemp(prefix=target + ".")
        config.set(section, derivedDataPath_option, tmpdir)

    # save config file
    with open(config_path, 'w') as fp:
        config.write(fp)

    # perform build
    param = ParamArray('-', FilterOut(target_option, config.items(section)))
    subprocess.call([section] + list(param))


if __name__ == '__main__':
    main()
