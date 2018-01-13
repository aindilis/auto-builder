#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $c = read_file('/var/lib/myfrdcsa/codebases/minor/auto-builder/data-git/build-logs/build-log.txt');
print $c."\n";

# '[ERROR] /media/andrewdo/s3/sandbox/bettyprimacy-20170722/bettyprimacy-20170722/src/test/java/com/timerchina/ptm/TemplateMerger.java:[7,16] error: package org.junit does not exist'

