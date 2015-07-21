#!/usr/bin/perl

use strict;
use warnings;

use MySession;
use Model::Counter;
use Model::Chat;

=pod
ここで設定する
=cut
my $set={};
$set->{'count_file'} = "count.cgi";
$set->{'log_file'} = "log.cgi";

my $ms = MySession->new(
	dir => './tmp',
	expire => '+1h'
);
my $counter = Model::Counter->new(
	save_file => $set->{'count_file'},
);
my $chat = Model::Chat->new(
	save_file => $set->{'count_file'},
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
<p>貴方は@{[$count->countup]}人目です</p>
<p><pre>
EOF

my $data = $chat($ms->params->{'message'})
for(@$data){ 
	$tx_buff .= <<"EOF";
$_[0]($_[1]->ymd $_[1]->hms)<br>
EOF
}
$tx_buff .= <<"EOF";
</pre></p>
<form method="POST" action="count2.cgi">
<label for="message">メッセージをどうぞ</label>
<textarea id="message" name="message"></textarea>
</form>
</body>
</html>
EOF

print $tx_buff;
