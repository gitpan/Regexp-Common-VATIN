package Regexp::Common::VATIN;

use strict;
use warnings FATAL => "all";
use utf8;
use Regexp::Common qw(pattern clean no_defaults);

our $VERSION = 'v0.0.8'; # VERSION
# ABSTRACT: Patterns for matching EU VAT Identification Numbers

my $a  = "[a-zA-Z]";
my $an = "[0-9a-zA-Z]";
my $d  = "[0-9]";
my $s  = "[ ]?";

# repeats:
my ($r2, $r3, $r4, $r5, $r7, $r8, $r9, $r10, $r11, $r12) = map {
    "{" . $_ . "}"
} 2..5, 7..12;

my $uk_pattern = do {
    my $multi_block  = "$d$r3$s$d$r4$s$d$r2$s(?:$d$r3)?";
    my $single_block = "(?:GD|HA)$d$r3";
    "(?:$multi_block|$single_block)";
};

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
    ES => "$an$d$r7$an",              # Spain
    FI => "$d$r8",                    # Finland
    FR => "$an$r2$s$d$r9",            # France
    GB => $uk_pattern,                # United Kingdom
    HU => "$d$r8",                    # Hungary
    IE => "${d}[0-9a-zA-Z+*]$d$r5$a", # Ireland
    IM => $uk_pattern,                # Isle of Man
    IT => "$d$r11",                   # Italy
    LT => "(?:$d$r9|$d$r12)",         # Lithuania
    LU => "$d$r8",                    # Luxembourg
    LV => "$d$r11",                   # Latvia
    MT => "$d$r8",                    # Malta
    NL => "$d${r9}[bB]$d$r2",         # The Netherlands
    PL => "$d$r10",                   # Poland
    PT => "$d$r9",                    # Portugal
    RO => "${d}{2,10}",               # Romania
    SE => "$d$r12",                   # Sweden
    SK => "$d$r10"                    # Slovakia
);

foreach my $alpha2 ( keys %patterns ) {
    my $prefix = $alpha2 eq "IM" ? "GB" : $alpha2;
    pattern(
        name   => ["VATIN", $alpha2],
        create => "$prefix$patterns{$alpha2}"
    );
};
pattern(
    name   => [qw(VATIN any)],
    create => do {
        my $any = join("|", map { "$_$patterns{$_}" } keys %patterns);
        "(?:$any)";
    }
);

1;
=encoding utf8

=head1 NAME

Regexp::Common::VATIN - Patterns for matching EU VAT Identification Numbers

=head1 SYNOPSIS

    use feature qw(say);
    use Regexp::Common qw(VATIN);
    say "DE123456789" =~ $RE{VATIN}{DE};  # 1
    say "DE123456789" =~ $RE{VATIN}{any}; # 1
    say "LT123ABC"    =~ $RE{VATIN}{LT};  # ""

=head1 DESCRIPTION

This module provides regular expression patterns to match any of the sanctioned
VATIN formats from the 26 nations levying a European Union value added tax.

=head1 JAVASCRIPT

All patterns in this module are written to be compatible with JavaScript's
somewhat less-expressive regular expression standard. They can thus easily be
exported for use in a browser-facing web application:

    use JSON qw(encode_json);
    my $patterns = encode_json($RE{VATIN});

=head1 CAVEAT

In keeping with the standard set by the core L<Regexp::Common> modules, patterns
are neither anchored nor enclosed with word boundaries. Consider a malformed
VATIN, e.g.,

    my $vatin = "GB1234567890";

According to the sanctioned patterns from the United Kingdom, the above VATIN is
malformed (one digit too many). And yet,

    say $vatin =~ $RE{VATIN}{GB};     # 1

To test for an exact match, use start and end anchors:

    say $vatin =~ /^$RE{VATIN}{GB}$/; # ""

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
