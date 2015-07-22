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

has 'seq' => (
	is => 'ro',
	isa => 'Int',
);

has 'msg' => (
	is => 'rw',
	isa => 'Maybe[Str]',
);

sub rw_log{
	my ($self) = @_;
	
	open(LFH,"<",$self->save_file) or die("Failed to open chat log");
	flock(LFH,1);
	my @raw = <LFH>;
	close(LFH);

	my $last;
	my $data=[];
	foreach my $lines (@raw){
		my ($id,$seq,$time,$msg) = split(/<>/,$lines);
		$msg =~ s/\n$//g;

		push($data,{
				seq=>$seq,
				msg=>$msg,
				timestamp=>Time::Piece->strptime($time+32400,"%s")
			}
		);
		if(defined($self->msg)){
			if($self->id eq $id){
				$last = {
					id => $id,
					time => $time,
					msg => $msg
				};
			}
		}
	}

	my $new_msg = $self->msg;

	$new_msg =~ s/&/&amp;/g;
	$new_msg =~ s/</&lt;/g;
	$new_msg =~ s/>/&gt;/g;
	$new_msg =~ s/[\n|\r]//g;

	unless(defined($last->{'msg'})){
		$last->{'msg'} = "<>";	
	}

	unless($new_msg eq $last->{'msg'} || $new_msg eq ''){

		open(LFH,">>",$self->save_file);
		flock(LFH,2);
		my $lt=localtime;
		print LFH <<"EOF";
@{[$self->id]}<>@{[$self->seq]}<>@{[$lt->epoch]}<>@{[$new_msg]}
EOF
		close(LFH);
		push($data,{
				seq=>$self->seq,
				msg=>$new_msg,
				timestamp=>$lt
			}
		);

	}
	return $data;
}
	
1;
