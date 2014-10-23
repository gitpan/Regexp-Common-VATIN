package Regexp::Common::VATIN;

use strict;
use warnings FATAL => "all";
use utf8;
use Regexp::Common qw(pattern clean no_defaults);

our $VERSION = 'v0.0.4'; # VERSION
# ABSTRACT: Patterns for matching EU VAT Identification Numbers

my $a  = "[a-zA-Z]";
my $an = "[0-9a-zA-Z]";
my $d  = "[0-9]";
my $s  = "[ ]?";

# repeats:
my ($r2, $r3, $r4, $r5, $r8, $r9, $r10, $r11, $r12) = map {
    "{" . $_ . "}"
} 2..5, 8..12;

my %patterns = (
    AT => "U$d$r8",                   # Austria
    BE => "0$d$r9",                   # Belgium
    BG => "${d}{9,10}",               # Bulgaria
    CY => "$d$r8$a",                  # Cyprus
    CZ => "${d}{8,10}",               # Czech Republic
    DE => "$d$r9",                    # Germany
    DK => "(?:$d$r2$s){3}$d$r2",      # Denmark
    EE => "$d$r9",                    # Estonia
    EL => "$d$r9",                    # Greece
    ES => "$d$r9",                    # Spain
    FI => "$d$r8",                    # Finland
    FR => "$an$r2$s$d$r9",            # France
    GB => do {                                # United Kingdom
        my $multi_block  = "$d$r3$s$d$r4$s$d$r2$s(?:$d$r3)?";
        my $single_block = "(?:GD|HA)$d$r3";
        "(?:$multi_block|$single_block)";
    },
    HU => "$d$r8",                    # Hungary
    IE => "${d}[0-9a-zA-Z+*]$d$r5$a", # Ireland
    HU => "$d$r11",                   # Italy
    LT => "(?:$d$r9|$d$r12)",         # Lithuania
    LU => "$d$r8",                    # Luxembourg
    LV => "$d$r11",                   # Latvia
    MT => "$d$r8",                    # Malta
    NL => "$d$r12",                   # The Netherlands
    PL => "$d$r10",                   # Poland
    PT => "$d$r9",                    # Portugal
    RO => "${d}{2,10}",               # Romania
    SE => "$d$r12",                   # Sweden
    SK => "$d$r10"                    # Slovakia
);

foreach my $alpha2 ( keys %patterns ) {
    pattern(
        name   => ["VATIN", $alpha2],
        create => "\\b$alpha2$patterns{$alpha2}\\b"
    );
};
pattern(
    name   => [qw(VATIN any)],
    create => do {
        my $any = join("|", map { "$_$patterns{$_}" } keys %patterns);
        "\\b(?:$any)\\b";
    }
);

1;
=encoding utf8

=head1 NAME

Regexp::Common::VATIN - Patterns for matching EU VAT Identification Numbers

=head1 SYNOPSIS

    use Regexp::Common qw(VATIN);
    "DE123456789" =~ $RE{VATIN}{DE};  # true
    "DE123456789" =~ $RE{VATIN}{any}; # true
    "LT123ABC"    =~ $RE{VATIN}{LT};  # false

=head1 DESCRIPTION

This module provides regular expression patterns to match any of the sanctioned
VATIN formats from the 26 nations levying a European Union value added tax.

=head1 SEE ALSO

=over

=item L<Regexp::Common>

For documentation of the interface this set of regular expressions uses.

=item L<Business::Tax::VAT::Validation>

Checks the official EU database for registered VATINs.

=back

=head1 AUTHOR

Richard Simões C<< <rsimoes AT cpan DOT org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2013 Richard Simões. This module is released under the terms of the
B<MIT License> and may be modified and/or redistributed under the same or any
compatible license.
