#!/usr/bin/perl -w

use BOSS::Config;
use Capability::WebSearch;
# use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;

use URL::Encode qw(url_encode);
# use WWW::Mechanize::Firefox;

$specification = q(
	-d <dir>		Directory to build
	-c <command>		Command
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

# my $cacher = PerlLib::Cacher->new
#    (
#     Expires => "never",
#     CacheRoot => "/var/lib/myfrdcsa/codebases/minor/auto-builder/data-git/FileCache",
#    );
# my $firefox = WWW::Mechanize::Firefox->new();

my $websearch = Capability::WebSearch->new();;

my $builddir;
if (! exists $conf->{'-d'}) {
  $builddir = "/var/lib/myfrdcsa/sandbox/seq-opt-hspsf-20170330/seq-opt-hspsf-20170330";
}
my $buildcommand;
if (! exists $conf->{'-c'}) {
  $buildcommand = "./build";
}

my $buildlogfile = "/var/lib/myfrdcsa/codebases/minor/auto-builder/data-git/build-logs/seq-opt-hspsf-20170330-build-log.txt";

my $logic =
  [
   {
    Example => 'hsp_f.ccx:1753:8: error: ‘abort’ was not declared in this scope',
    Error => "\"error: ‘\$4’ was not declared in this scope\"",
    Regex => {
	      Regex => '.*(.+?):(\d+):(\d+): error: ‘(.+?)’ was not declared in this scope',
	      Assignment => {
			     1 => 'filename',
			     2 => 'line_number',
			     3 => 'column_number',
			     4 => 'function name',
			    },
	     },
    SolutionCache => [
		      {
		       Error => "error: ‘abort’ was not declared in this scope",
		       Solution => sub {
			 my (%args) = @_;
			 my $filename = $args{Results}{filename};
			 addStatementToSource(SourceFilename => $filename, Code => 'include <cstdlib>');
		       },
		       Provenance => 'http://www.qtcentre.org/archive/index.php/t-29696.bhtml',
		      },
		     ],
   },
   {
    Example => 'hsp_f.ccx:5946:72: error: conflicting declaration ‘hsps::ExecError::ErrorSeverity s’',
    Error => "\"error: conflicting declaration ‘\$4’\"",
    Regex => {
	      Regex => '.*(.+?):(\d+):(\d+): error: conflicting declaration ‘(.+?)’.*',
	      Assignment => {
			     1 => 'filename',
			     2 => 'line_number',
			     3 => 'column_number',
			     4 => 'function name',
			    },
	     },

   },
  ];

my $buildlog;
if (! -e $buildlogfile) {
  my $c = 'cd '.shell_quote($builddir).' && '.$buildcommand;
  print $c."\n";
  $buildlog = `$c`;
} else {
  $buildlog = read_file($buildlogfile);
}

ProcessBuildLog(Log => $buildlog);

sub ProcessBuildLog {
  my (%args) = @_;
  my $results = {};
  foreach my $entry (@$logic) {
    my $regex = $entry->{Regex}{Regex};
    print "<$regex>\n";
    if ($args{Log} =~ /$regex/sm) {

      print $entry->{Error}."\n";
      my $error = eval $entry->{Error};
      foreach my $key (keys %{$entry->{Regex}{Assignment}}) {
	$results->{$entry->{Error}}{$entry->{Regex}{Assignment}{$key}} = eval "\$$key";
      }
      # print Dumper({Results => $results});
      my $res1 = GetSolutionForError(Entry => $entry, Results => $results, Error => $error);
      print Dumper({Res1 => $res1});
    }
  }
}

sub GetSolutionForError {
  my (%args) = @_;
  print Dumper({Args => \%args});
  my @results;
  if (exists $args{Entry}{SolutionCache}) {
    foreach my $solutionconcept (@{$args{Entry}{SolutionCache}}) {
      if ($args{Error} eq $solutioncache->{Error}) {
	my $res1 = $solutioncache->{Solution}->(Entry => $args{Entry}, Error => $args{Error});
	push @results, $res1;
      }
    }
  } else {
    @results = LookupSolutionForError(Error => $args{Error});
  }
  return \@results;
}

sub LookupSolutionForError {
  my (%args) = @_;
  # include in this system the ability to remote control Emacs w3m to get results
  if (0) {
    my $quotedsearch = shell_quote($args{Error});
    my $command = "google -s $quotedsearch";
    print $command."\n";
    system $command;
  } else {
    # my $octets = url_encode($args{Error});
    # my $url = "https://www.google.com/#safe=active\&q=$octets\&\*";
    # # $cacher->get($url);
    # # print $cacher->content();

    # $firefox->get($url);
    # print $firefox->content();
    print Dumper($websearch->WebSearch(Search => $args{Error}));
  }
  # obtain solution
  GetSignalFromUserToProceed();
  return 0;
}

sub addStatementToSource {
  my (%args) = @_;
  # $args{Results}->{filename},
  # $args{SourceFilename};
  # 'include <cstdlib>');
  # $args{Code};
  print "execute prologAgent command to edit the file\n";
}
