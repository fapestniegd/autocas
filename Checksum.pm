ackage Apache2::Checksum;

use strict;
use warnings;
use Data::Dumper;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Filter ();
use APR::Brigade ();
use APR::Bucket ();

use Apache2::Const -compile => qw(OK M_PUT);

sub handler {
    my $r = shift;
    print STDERR Data::Dumper->Dump([$r]);
    my $length;
    if ($r->method_number == Apache2::Const::M_PUT) {
          my $data = content($r);
          $r->print("content:\n$data\n");
    }
    return Apache2::Const::OK;
}

use Apache2::Connection ();

use Apache2::Const -compile => qw(MODE_READBYTES);
use APR::Const     -compile => qw(SUCCESS BLOCK_READ);

use constant IOBUFSIZE => 8192;

sub content{
    my $r = shift;

    my $bb = APR::Brigade->new($r->pool, $r->connection->bucket_alloc);

    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);

        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }

            if ($b->read(my $buf)) {
                $data .= $buf;
            }

            $b->remove; # optimization to reuse memory
        }
    } while (!$seen_eos);

    $bb->destroy;

    print STDERR __PACKAGE__."::handler -> ".Data::Dumper->Dump([$data])."\n";
    return $data;
}
1;
