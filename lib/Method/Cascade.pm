package Method::Cascade;

use strict;

our $VERSION = '0.100';

require Exporter;
use base 'Exporter';
our @EXPORT = qw(cascade);


sub cascade {
  my $wrapped = shift;
  return bless { w => $wrapped, }, 'Method::Cascade::Wrapper'; 
}


package Method::Cascade::Wrapper;

use strict;

our $AUTOLOAD;

sub AUTOLOAD {
  my $self = shift;

  my $method = $AUTOLOAD;
  $method =~ s/.*://;

  $self->{w}->$method(@_);

  return $self;
}

1;


__END__


=encoding utf-8

=head1 NAME

Method::Cascade - Use method chaining with any API

=head1 SYNOPSIS

    use Method::Cascade;
    use IO::Socket;

    my $sock = IO::Socket::INET->new('google.com:http(80)');

    cascade($sock)
      ->timeout(5)
      ->setsockopt(SOL_SOCKET, SO_KEEPALIVE, pack("l", 1))
      ->print("GET / HTTP/1.0\r\n\r\n")
      ->recv(my $response, 4096);

    print $response;


=head1 DESCRIPTION

Method chaining is a very intuitive and convenient way to make sequential method calls on the same object.

Unfortunately, not all APIs support chaining. In order for an API to be chainable, every method must return C<$self>. However often there are good reasons for APIs to not return C<$self>. Sometimes, for instance, it is useful for setter methods to return the previous value.

Method cascading is a feature borrowed from Smalltalk. Its advantage is that any API can be used in a chaining fashion, even if the designers didn't plan or intend for it to be chainable. You, the user of the API, can choose if you care about the return values and, if not, go ahead and cascade method calls.

Because the return values are ignored (the methods are in fact called in void context), method cascading is most useful when used with APIs that throw exceptions on errors instead of returning error values. For instance, as long as C<RaiseError> is in place, with method cascading you can use L<DBI> like so:

    cascade($dbh)->do("INSERT INTO admins (name) VALUES (?)", undef, $user)
                 ->do("DELETE FROM users WHERE name=?", undef, $user)
                 ->commit;


=head1 OTHER LANGUAGES

As mentioned, method cascading was first invented in Smalltalk.

L<Dart|https://www.dartlang.org/> is a web-language that has also added this feature. In Dart, the C<..> operator is a method cascading operator that returns the object the method was invoked on instead of the method call result. Here is a Dart example:

    myTokenTable
      ..add("aToken")
      ..add("anotherToken")
      // and on and on
      ..add("theUmpteenthToken");



=head1 SEE ALSO

L<The Method::Cascade github repo|https://github.com/hoytech/Method-Cascade>

L<Method Cascades in Dart|http://news.dartlang.org/2012/02/method-cascades-in-dart-posted-by-gilad.html>

L<Wikipedia entry|https://en.wikipedia.org/wiki/Method_cascading>


=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2014 Doug Hoyte.

This module is licensed under the same terms as perl itself.

=cut
