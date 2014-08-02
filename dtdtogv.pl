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
    #print $fdot "edge [constrain=true];\n";
    #say  "edge [constrain=true];";

    for my $node (keys $dtd) {
        my $attributes = "";
        if (defined $dtd->{$node}->{att}) {
            for my $attkey (keys $dtd->{$node}->{att}) {
                if (defined $dtd->{$node}->{att}->{$attkey}) {
                    $attributes = join " ", $attributes, 
                                            $attkey,
                                            @{$dtd->{$node}->{att}->{$attkey}};
                }
            }
        }
        my $nodeatt = "dtd_$node [label=\"$node\", tooltip=\"$attributes\"]";
        if (defined $dtd->{$node}->{elm}) {
            my $elements = join(', dtd_', @{$dtd->{$node}->{elm}});

            #say $nodeatt;
            print $fdot "$nodeatt\n";
            #say "dtd_$node -> { dtd_$elements };";
            print $fdot "dtd_$node -> {dtd_$elements};\n";
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
