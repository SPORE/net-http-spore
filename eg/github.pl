use strict;
use warnings;

use Net::HTTP::Spore;
use Getopt::Long;

use Config::GitLike::Git;
use Git::Repository;

GetOptions(
    'spec=s' => \my $specification,
    'name=s' => \my $name,
    'desc=s' => \my $desc,
);

print ">> creating repository $name on github\n";

my $c = Config::GitLike::Git->new();
$c->load;

my $login = $c->get(key => 'github.user');
my $token = $c->get(key => 'github.token');

my $github = Net::HTTP::Spore->new_from_spec($specification);
$github->enable('Format::JSON');
$github->enable(
    'Auth::Basic',
    username => $login . '/token',
    password => $token,
);

my $remote = "git\@github.com:" . $login . "/" . $name . ".git";

my $res = $github->create_repo(format => 'json', payload => {name => $name, description => $desc});

print ">> repository $remote created\n";

my $r = Git::Repository->create(init => $name);
my @cmd = ('remote', 'add', 'origin', $remote);
$r->run(@cmd);

print ">> repository cloned to $name\n";
print ">> done!\n";
