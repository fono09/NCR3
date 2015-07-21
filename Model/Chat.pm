use Moose;
use Time::Piece;

has 'save_file' => (
	is => 'ro'
	isa => 'Str',
);
has 'id' => (
	is => 'ro',
	isa => 'Str'
);

sub rw_log{
	my ($self,$msg) = @_;
	
	open(LFH,"<",$self->save_file);
	flock(LFH,1);
	my @raw = <LFH>;
	close(LFH);

	my $data,$last;
	foreach $lines (@raw){
		my ($id,$time,$msg) = split(/<>/,$lines);
		push($data,[$msg,Time::Piece->strptime($time,"%s")]);

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

	if(defined($msg)){
		unless($last->{'msg'} eq $msg){
			$msg =~ s/<.+?>//g;

			open(LFH,"+>>",$self->save_file);
			flock(LFH,2);
			my $lt=localtime;
			print LFH <<"EOF";
@{[$self->id]}<>@{[$lt->epoch]}<>$msg
EOF
			close(LFH);
		}
	}

	return $data;
}
	
1;
