package ep::Config;
use strict;

=head1 NAME

ep::Config - The Extopus File

=head1 SYNOPSIS

 use ep::Config;

 my $parser = ep::Config->new(file=>'/etc/extopus/system.cfg');

 my $cfg = $parser->parse_config();
 my $pod = $parser->make_pod();

=head1 DESCRIPTION

Configuration reader for Extopus

=cut

use vars qw($VERSION);
$VERSION   = '0.01';
use Carp;
use Config::Grammar;
use Mojo::Base -base;

has 'file';
    

=head1 METHODS

All methods inherited from L<Mojo::Base>. As well as the following:

=cut

=head2 $x->B<parse_config>(I<path_to_config_file>)

Read the configuration file and die if there is a problem.

=cut

sub parse_config {
    my $self = shift;
    my $cfg_file = shift;
    my $parser = $self->_make_parser();
    my $cfg = $parser->parse($self->file) or croak($parser->{err});
    return $cfg;
}

=head2 $x->B<make_config_pod>()

Create a pod documentation file based on the information from all config actions.

=cut

sub make_pod {
    my $self = shift;
    my $parser = $self->_make_parser();
    my $E = '=';
    my $footer = <<"FOOTER";

${E}head1 COPYRIGHT

Copyright (c) 2011 by OETIKER+PARTNER AG. All rights reserved.

${E}head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

${E}head1 AUTHOR

S<Tobias Oetiker E<lt>tobi\@oetiker.chE<gt>>

${E}head1 HISTORY

 2011-04-19 to 1.0 first version

FOOTER
    my $header = $self->_make_pod_header();    
    return $header.$parser->makepod().$footer;
}



=item $x->B<_make_pod_header>()

Returns the header of the cfg pod file.

=cut

sub _make_pod_header {
    my $self = shift;
    my $E = '=';
    return <<"HEADER";
${E}head1 NAME

extopus.cfg - The Extopus configuration file

${E}head1 SYNOPSIS

 *** GENERAL ***
 cache_dir = /scratch/extopus
 mojo_secret = MyCookieSecret
 log_file = /tmp/dbtoria.log

 *** INVENTORY: siam1 ***
 module=SIAM
 driver=Simple
 +Driver_Options
 dsn = ...
 username = ...
 password = ...
  
 *** CONNECTOR: torrus ***
 module=torrus

${E}head1 DESCRIPTION

Configuration overview

${E}head1 CONFIGURATION

HEADER

}

=item $x->B<_make_parser>()

Create a config parser for DbToRia.

=cut

sub _make_parser {
    my $self = shift;
    my $E = '=';
    my $grammar = {
        _sections => [ qw{GENERAL /(INVENTORY|CONNECTOR):.+\S/}],
        _mandatory => [qw(GENERAL)],
        GENERAL => {
            _doc => 'Global configuration settings for Extopus',
            _vars => [ qw(cache_dir mojo_secret log_file) ],
            _mandatory => [ qw(cache_dir mojo_secret log_file) ],
            cache_dir => { _doc => 'directory to cache information gathered via the inventory plugins' },
            mojo_secret => { _doc => 'secret for signing mojo cookies' },
            log_file => { _doc => 'write a log file to this location'},
        },
        '/(INVENTORY|CONNECTOR):.+\S/' => {
            _doc => 'Instanciate an inventory object',
            _vars => [ '/[a-z]\S+/' ],
            _sections => [ '/[A-Z]\S+/' ],
            '/[a-z]\S+/' => {
                _doc => 'Any key value settings appropriate for the instance at hand'
            },
            '/[A-Z]\S+/' => {
                _doc => 'Grouped configuraiton options like SIAM Driver configuration',
                _vars => [ '/[a-z]\S+/' ],
                '/[a-z]\S+/' => {             
                    _doc => 'Any key value settings appropriate for the instance at hand'
                }        
            },
        },

    };
    my $parser =  Config::Grammar->new ($grammar);
    return $parser;
}

1;
__END__

=back

=head1 COPYRIGHT

Copyright (c) 2011 by OETIKER+PARTNER AG. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=head1 AUTHOR

S<Tobias Oetiker E<lt>tobi@oetiker.chE<gt>>

=head1 HISTORY

 2011-02-19 to 1.0 first version

=cut

# Emacs Configuration
#
# Local Variables:
# mode: cperl
# eval: (cperl-set-style "PerlStyle")
# mode: flyspell
# mode: flyspell-prog
# End:
#
# vi: sw=4 et

