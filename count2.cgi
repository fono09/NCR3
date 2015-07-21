#!/usr/bin/perl

use strict;
use warnings;

use MySession;
use Model::Counter;
use Model::Chat;
use Time::Piece;

use Data::Dumper;

=pod
ここで設定する
=cut
my $set={};
$set->{'count_file'} = "./count.cgi";
$set->{'log_file'} = "./log.cgi";

my $ms = MySession->new(
	dir => './tmp',
	expire => '+1h'
);
$ms->flush;

my $counter = Model::Counter->new(
	save_file => $set->{'count_file'},
);
my $chat = Model::Chat->new(
	save_file => $set->{'log_file'},
	id => $ms->sess->id,
);

my $tx_buff .= $ms->header;
$tx_buff .= << "EOF";
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>なんか具合にチャット</title>
</head>
<body>
<h1>なんかいい具合にチャット</h1>
<p>貴方は@{[$counter->count_up]}人目です</p>
<div><pre>
EOF
my $data = $chat->rw_log($ms->cgi->Vars->{'message'});
for(@$data){ 
	$tx_buff .= '<p>'.$_->[0].'('.$_->[1]->ymd.','.$_->[1]->hms.')</p>';
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
