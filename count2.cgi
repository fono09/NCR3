#!/usr/bin/perl

use strict;
use warnings;

use MySession;
use Model::Counter;
use Model::Chat;
use Time::Piece;

use Data::Dumper;

my $set={};
$set->{'count_file'} = "./count.cgi";
$set->{'log_file'} = "./log.cgi";

my $ms = MySession->new(
	dir => './tmp',
	expire => '+1h'
);

my $counter = Model::Counter->new(
	save_file => $set->{'count_file'},
);
my $cnt = $counter->count_up;

my $cgi_params = $ms->cgi->Vars;

my $chat = Model::Chat->new(
	save_file => $set->{'log_file'},
	seq => $cnt,
	id => $ms->sess->id,
	msg => $cgi_params->{'message'},
);

my $tx_buff .= $ms->header;
$tx_buff .= << "EOF";
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>なんかいい具合にチャット</title>
</head>
<body>
<h1>なんかいい具合にチャット</h1>
<p>貴方は$cnt人目です</p>
<div><pre>
EOF
my $log = $chat->rw_log($ms->cgi->Vars->{'message'});
for(@$log){
	$tx_buff .= '<p>['.$_->{'seq'}.']'.$_->{'msg'}.'('.$_->{'timestamp'}->ymd.','.$_->{'timestamp'}->hms.')</p>';
}

$tx_buff .= <<"EOF";
</pre></div>
<form method="POST" action="count2.cgi">
<label for="message">メッセージをどうぞ</label>
<input type="text" id="message" name="message"></textarea>
<input type="submit" value="送信">
</form>
</body>
</html>
EOF

print $tx_buff;
$ms->flush;
