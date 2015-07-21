use Moose;

has 'save_file' => (
	is => 'ro',
	isa => 'Str',
);

sub count_up{
	my $self = shift;
	
	open(CFH,">>+",$self->save_file);
	flock(CFH,2);
	my $count=<CFH>;
	seek(CFH,0,0);
	truncate(CFH,0);
	$count++;
	print CFH $count;
	close(CFH);

	return $count;
}

1;
