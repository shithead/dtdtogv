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
            $part =~ s/[\,\+]// ;
            $dtd->{$key}->{elm}[$new_idx] = $part ;
            $new_idx++;
        }
    }
}
sub attlist(@) {
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
    p $dtd;
}

p @ARGV;
&main(@ARGV);
