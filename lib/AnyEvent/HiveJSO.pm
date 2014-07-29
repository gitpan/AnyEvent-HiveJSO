package AnyEvent::HiveJSO;
BEGIN {
  $AnyEvent::HiveJSO::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO stream serializer/deserializer for AnyEvent
$AnyEvent::HiveJSO::VERSION = '0.001';
use strict;
use warnings;

use AnyEvent::Handle;
use HiveJSO;
use Carp qw( croak );

AnyEvent::Handle::register_write_type(hivejso => sub {
  my ($self, @args) = @_;
  return HiveJSO->new({ @args })->hivejso if scalar @args > 1;
  my $data = $args[0];
  my $ref = ref $data;
  if ($ref eq 'HASH') {
    return HiveJSO->new($data);
  } elsif ($ref eq 'ARRAY') {
    return HiveJSO->new({ @{$data} });    
  } elsif ($data->can('hivejso')) {
    return $data->hivejso;
  }
  croak __PACKAGE__." can't handle this data with ref ".$ref;
});

AnyEvent::Handle::register_read_type(hivejso => sub {
  my ( $self, $cb ) = @_;
  sub {
    my ( $obj, $post ) = HiveJSO->parse_seek($_[0]{rbuf});
    if ($obj) {
      $_[0]{rbuf} = $post;
      $cb->( $_[0], $obj );
      return 1;
    }
    return 0;
  };
});

1;

__END__

=pod

=head1 NAME

AnyEvent::HiveJSO - HiveJSO stream serializer/deserializer for AnyEvent

=head1 VERSION

version 0.001

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
