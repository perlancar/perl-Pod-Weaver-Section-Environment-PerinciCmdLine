package Pod::Weaver::Section::Environment::PerinciCmdLine;

# DATE
# VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::AddTextToSection';
with 'Pod::Weaver::Role::DetectPerinciCmdLineScript';
with 'Pod::Weaver::Role::AddTextToSection';
with 'Pod::Weaver::Role::Section';

use List::Util qw(first);
use Moose::Autobox;

sub weave_section {
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';
    if ($filename !~ m!^(bin|script)/!) {
        $self->log_debug(["skipped file %s (not bin/script)", $filename]);
        return;
    }

    my $res = $self->detect_perinci_cmdline_script($input);
    if ($res->[0] != 200) {
        die "Can't detect Perinci::CmdLine script for $filename: $res->[0] - $res->[1]";
    } elsif (!$res->[2]) {
        $self->log_debug(["skipped file %s (not a Perinci::CmdLine script: %s)", $filename, $res->[3]{'func.reason'}]);
        return;
    }

    $res = $self->dump_perinci_cmdline_script($input);
    if ($res->[0] != 200) {
        die "Can't dump Perinci::CmdLine script for $filename: $res->[0] - $res->[1]";
    }
    my $cli = $res->[2];

    unless ($cli->{read_env}) {
        $self->log_debug(["skipped file %s (script does not read env)", $filename]);
        return;
    }

    my $text = $cli->{env_name};

    $self->add_text_to_section($document, $text, 'ENVIRONMENT');
}

no Moose;
1;
# ABSTRACT: Add a COMPLETION section for Perinci::CmdLine-based scripts

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [Completion::PerinciCmdLine]


=head1 DESCRIPTION

This section plugin adds a COMPLETION section for Perinci::CmdLine-based
scripts. The section contains information on how to activate shell tab
completion for the scripts.


=head1 SEE ALSO

L<Perinci::CmdLine>

=cut
