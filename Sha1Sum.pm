package Apache2::Sha1Sum;

use strict;
use warnings;

use base qw(Apache2::Filter);

use Apache2::Const -compile => 'OK';

use constant BUFF_LEN => 1024;
use Data::Dumper;
use Digest::SHA1;

sub handler : FilterRequestHandler {
    my $f = shift;
    print STDERR __PACKAGE__."::handler\n";
    my $r = $f->r;
    my $ctx = $f->ctx;
    unless (defined($ctx)) {
        $ctx = { 
                 'sha1sum' => Digest::SHA1->new ,
                 'count'   => 0,
               };
    }
    ############################################################################
    # Here we can block hash (and encrypt if need be)
    ############################################################################
    while ($f->read(my $buffer, BUFF_LEN)) {
        $f->print($buffer);
        $ctx->{'sha1sum'}->add($buffer);
        $ctx->{'count'}+=length($buffer);
    }
    $r->subprocess_env('sha1sum' => $ctx->{'sha1sum'}->clone->hexdigest);
    $r->pnotes({ 
                 'sha1sum' => $ctx->{'sha1sum'}->clone->hexdigest,
               });
    $f->ctx($ctx);
    Apache2::Const::OK;
}
1;
