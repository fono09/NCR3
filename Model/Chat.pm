package Model::Chat;

use Moose;
use Time::Piece;

has 'save_file' => (
	is => 'ro',
	isa => 'Str',
);
has 'id' => (
	is => 'ro',
	isa => 'Str',
);

sub rw_log{
	my ($self,$msg) = @_;
	
	open(LFH,"<",$self->save_file) or die("Failed to open chat log");
	flock(LFH,1);
	my @raw = <LFH>;
	close(LFH);

	my $last;
	my $data=[];
	foreach my $lines (@raw){
		my ($id,$time,$msg) = split(/<>/,$lines);
		$msg =~ s/\n$//g;

		push($data,[$msg,Time::Piece->strptime($time+32400,"%s")]);
		if(defined($msg)){
			if($self->id eq $id){
				$last = {
					id => $id,
					time => $time,
					msg => $msg
				};
			}
		}
	}

	$msg =~ s/&/&amp;/g;
	$msg =~ s/</&lt;/g;
	$msg =~ s/>/&gt;/g;
	$msg =~ s/[\n|\r]//g;

	unless(defined($last->{'msg'})){
		$last->{'msg'} = "<>";	
	}

	unless($msg eq $last->{'msg'} || $msg eq ''){

		open(LFH,">>",$self->save_file);
		flock(LFH,2);
		my $lt=localtime;
		print LFH <<"EOF";
@{[$self->id]}<>@{[$lt->epoch]}<>@{[$msg]}
EOF
		close(LFH);
		push($data,[$msg,$lt])
	}

	return $data;
}
	
1;
