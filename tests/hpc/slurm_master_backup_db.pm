# SUSE's openQA tests
#
# Copyright 2017-2019 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Slurm accounting - database
#    This test is setting up slurm control backup node with accounting
#    configured (database)
# Maintainer: Kernel QE <kernel-qa@suse.de>

use Mojo::Base 'hpcbase', -signatures;
use testapi;
use serial_terminal 'select_serial_terminal';
use lockapi;
use utils;
use hpc::utils 'get_slurm_version';

sub run ($self) {
    select_serial_terminal();
    my $nodes = get_required_var("CLUSTER_NODES");
    my $slurm_pkg = get_slurm_version(get_var('SLURM_VERSION', ''));

    barrier_wait('CLUSTER_PROVISIONED');

    $self->prepare_user_and_group();
    # $slurm_pkg-munge is installed explicitly since slurm_23_02
    zypper_call("in $slurm_pkg $slurm_pkg-munge");

    # mount NFS shared directory specific
    # for this test /shared/slurm and provided by the
    # supportserver
    $self->mount_nfs();

    barrier_wait("SLURM_SETUP_DONE");
    barrier_wait('SLURM_SETUP_DBD');
    barrier_wait("SLURM_MASTER_SERVICE_ENABLED");
    record_info('slurm conf', script_output('cat /etc/slurm/slurm.conf'));
    $self->enable_and_start('munge');
    $self->enable_and_start('slurmctld');
    systemctl 'status slurmctld';
    $self->enable_and_start('slurmd');
    systemctl 'status slurmd';

    # wait for slave to be ready
    barrier_wait("SLURM_SLAVE_SERVICE_ENABLED");
    barrier_wait('SLURM_MASTER_RUN_TESTS');
}

sub test_flags ($self) {
    return {fatal => 1, milestone => 1};
}

sub post_fail_hook ($self) {
    $self->destroy_test_barriers();
    select_serial_terminal;
    $self->upload_service_log('slurmd');
    $self->upload_service_log('munge');
    $self->upload_service_log('slurmctld');
    upload_logs('/var/log/slurmctld.log', failok => 1);
}

1;
