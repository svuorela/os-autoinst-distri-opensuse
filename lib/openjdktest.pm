# Copyright 2023 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Base module for openJDK test cases
# Maintainer: QE Security <none@suse.de>

package openjdktest;

use base Exporter;
use Exporter;

use consoletest;
use strict;
use warnings;
use testapi;
use utils;

our @EXPORT = qw(
  remove_any_installed_java
);

sub remove_any_installed_java {
    my @output = grep /java-\d+-openjdk/, split(/\n/, script_output "rpm -qa 'java-*'");
    return unless scalar @output;    # nothing to remove
    my $pkgs = join ' ', @output;
    zypper_call "rm ${pkgs}";
}
