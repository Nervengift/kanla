use inc::Module::Install;
use Cwd;

name     'kanla';
all_from 'lib/Kanla.pm';
author   'Michael Stapelberg';

requires 'AnyEvent';
requires 'AnyEvent::Util';
requires 'AnyEvent::Handle';
requires 'AnyEvent::XMPP::Client';
requires 'AnyEvent::XMPP::Ext::Disco';
requires 'AnyEvent::XMPP::Ext::Ping';
requires 'AnyEvent::XMPP::Ext::VCard';
requires 'AnyEvent::XMPP::Ext::Version';
requires 'JSON::XS';
requires 'Config::General' => '2.50';

# plugin requirements
requires 'AnyEvent::HTTP';
requires 'AnyEvent::Socket';
requires 'AnyEvent::DNS';

install_script 'kanla';
# Install plugins/ into a distribution-shared directory
install_share('dist', 'plugins');

################################################################################
# We generate make targets for every file in docs/
# so users can use 'make docs'
# to generate docs/*.html from docs/*.txt
################################################################################

my @docs = <docs/*.txt>;
my $alldocfiles = join ' ', map { substr($_, 0, length() - 4) . '.html' } @docs;
my $postamble = '';
my $cwd = getcwd();

for my $file (@docs) {
	my $htmlfile = $file;
	$htmlfile =~ s/\.txt$/.html/;
$postamble .= <<EOT
$htmlfile: $file
	asciidoc -b html5 -f asciidoc.conf -a toc2 -a disable-javascript -a stylesheet=$cwd/asciidoc-toc.css -n -o - $file | hxtoc -l 2 > $htmlfile
EOT
}

postamble <<END_OF_MAKEFILE;
$postamble

docs: $alldocfiles
END_OF_MAKEFILE

WriteAll;