package Model::Counter;

use Moose;

has 'save_file' => (
	is => 'ro',
	isa => 'Str',
);

sub count_up{
	my $self = shift;
	
	open(CFH,"+<",$self->save_file) or die("Failed to open counter log");
	flock(CFH,2);
	my $count=<CFH>;
	$count++;
	truncate(CFH,0);
	seek(CFH,0,0);
	print CFH $count;
	flock(CFH,8);
	close(CFH);

	return $count;
}

1;
