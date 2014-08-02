#!/usr/bin/env perl5

use strict;
use warnings;
use feature 'say';
use Data::Printer;

our $dtd = {};


sub element {
    my $key = shift @_;
    my @tail = @_;
    my $new_idx = 0;
    while (@tail) {
        my $part = shift @tail;
        if ($part !~ '(\||\(|\)|>)') {
            $part =~ s/[\,\+\#]// ;
            $dtd->{$key}->{elm}[$new_idx] = $part ;
            $new_idx++;
        }
    }
}

sub attlist {
    my $key = shift @_;
    my $attkey = shift @_;
    my @tail = @_;
    my $new_idx = 0;
    while (@tail) {
        my $part = shift @tail;
        if ($part !~ '(>)') {
            $dtd->{$key}->{att}->{$attkey}[$new_idx] = $part ;
            $new_idx++;
        }
    }
}

sub graphviz {
    my ($fn, $suffix) = split /./, @_;
    $suffix = "dot";
    $fn = join('.', $fn,$suffix);
    open my $fdot, "> $fn" or die "Cann't open for write $fn";

    print $fdot "digraph dtd_flowchart {\n";
    #say "diagraph dtd_flowchart {";

    for my $key (keys $dtd) {
        if (defined $dtd->{$key}->{elm}) {
            my $elements = join(', dtd_', @{$dtd->{$key}->{elm}});

            #say "dtd_$key -> { dtd_$elements };";
            print $fdot "dtd_$key -> {dtd_$elements};\n";
        }
    }

    #say "}";
    print $fdot "}\n\n";
    close $fdot;
}

sub main {
    my $fn = shift @_;
    open my $fdtd, "< $fn" or die "Cann't open for read $fn";
    while (<$fdtd>) {
        chomp;
        my @line = split(/ /,$_);
        my $start = shift @line;
        if ($start) {
            &element(@line) if ( $start =~ m/<!ELEMENT/);
            &attlist(@line) if ( $start =~ m/<!ATTLIST/);
        }
    }
    close $fdtd;
    &graphviz($fn);
}

&main(@ARGV);
