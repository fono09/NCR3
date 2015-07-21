package MySession;

use Moose;
use CGI;
use CGI::Session;

has 'cgi' => (
	is => 'rw',
	isa => 'Maybe[CGI]',
);
	
has 'sess' => (
	is => 'rw',
	isa => 'Maybe[CGI::Session]',
);

has 'params' => (
	is => 'rw',
	isa => 'HashRef[Item]',
	builder => '_build_params',
);

has 'dir' => (
	is => 'ro',
	isa => 'Str',
);

has 'expire' => (
	is => 'ro',
	isa => 'Str',
);

sub BUILDARGS {
	my ($class,%args) = @_;
	
	unless($args{cgi}){
		$args{cgi} = CGI->new;
	}
	unless($args{sess}){
		
		my $sess = CGI::Session->new(
			undef,
			$args{cgi},
			{ Directory => "$args{dir}"},
		);
		$sess->expire($args{expire});

		my $params = $args{cgi}->Vars;
		for(keys $params){
			$sess->param($_,$params->{$_});
		}

		$args{params} = $sess->param_hashref;
		$args{sess} = $sess;

	}

	return \%args;
}

sub header{
	my ($self) = @_;

	return $self->sess->header(-charset => 'utf-8');
}


sub flush {
	my ($self) = @_;

	$self->sess->flush;
}

sub close {
	my ($self) = @_;

	$self->sess->close;
}

sub delete {
	my ($self) = @_;

	$self->sess->delete;
}
1;
