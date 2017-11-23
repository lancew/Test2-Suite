package Test2::Compare::Float;
use strict;
use warnings;

use Carp qw/confess/;

use base 'Test2::Compare::Base';

our $VERSION = '0.000086';

our $DEFAULT_TOLERANCE = 1e-08;

use Test2::Util::HashBase qw/input tolerance/;

# Overloads '!' for us.
use Test2::Compare::Negatable;

sub init {
    my $self      = shift;
    my $input     = $self->{+INPUT};

    $self->{+TOLERANCE} = $DEFAULT_TOLERANCE
      unless defined $self->{+TOLERANCE};

    confess "input must be defined for 'Float' check"
        unless defined $input;

    # Check for ''
    confess "input must be a number for 'Float' check"
        unless length($input) && $input =~ m/\S/;

    $self->SUPER::init(@_);
}

sub name {
    my $self      = shift;
    my $in        = $self->{+INPUT};
    my $tolerance = $self->{+TOLERANCE};
    return "$in +/- $tolerance";
}

sub operator {
    my $self = shift;
    return '' unless @_;
    my ($got) = @_;

    return '' unless defined($got);
    return '' unless length($got) && $got =~ m/\S/;

    return '!=' if $self->{+NEGATE};
    return '==';
}

sub verify {
    my $self = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;
    return 0 unless defined $got;
    return 0 if ref $got;
    return 0 unless length($got) && $got =~ m/\S/;

    my $input     = $self->{+INPUT};
    my $negate    = $self->{+NEGATE};
    my $tolerance = $self->{+TOLERANCE};

    my @warnings;
    my $out;
    {
        local $SIG{__WARN__} = sub { push @warnings => @_ };

        my $equal = ($input == $got);
        $equal = 1 if
          !$equal
          && $got > $input - $tolerance
          && $got < $input + $tolerance;

        $out = $negate ? !$equal : $equal;
    }

    for my $warn (@warnings) {
        if ($warn =~ m/numeric/) {
            $out = 0;
            next; # This warning won't help anyone.
        }
        warn $warn;
    }

    return $out;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Compare::Float - Compare two values as numbers with tolerance.

=head1 DESCRIPTION

This is used to compare two numbers. You can also check that two numbers are not
the same.

This is similar to Test2::Compare::Number, with extra checks to work around floating
point representation issues.

The optional 'tolerance' parameter controls how close the two numbers must be to
be considered equal.  Tolerance defaults to 1e-08.

B<Note>: This will fail if the received value is undefined. It must be a number.

B<Note>: This will fail if the comparison generates a non-numeric value warning
(which will not be shown). This is because it must get a number. The warning is
not shown as it will report to a useless line and filename. However, the test
diagnostics show both values.

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<http://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Andrew Grangaard E<lt>spazm@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2017 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut