package Apache2::S3Rename;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::ServerRec ();
use Apache2::Log ();

use File::Path;
use File::Basename;
use Data::Dumper;

# Compile constants
use Apache2::Const -compile => qw(DECLINED);

sub handler {
    my $r = shift;

    print STDERR __PACKAGE__."::handler\n";
    print STDERR "Craft a RESTObjectCOPY request".$r->filename." to ". $r->subprocess_env('sha1sum')."\n";
    #http://docs.amazonwebservices.com/AmazonS3/latest/API/index.html?RESTObjectCOPY.html
    #PUT /destinationObject HTTP/1.1
    #Host: destinationBucket.s3.amazonaws.com
    #x-amz-copy-source: /source_bucket/sourceObject
    #x-amz-metadata-directive: metadata_directive
    #x-amz-copy-source-if-match: etag
    #x-amz-copy-source-if-none-match: etag
    #x-amz-copy-source-if-unmodified-since: time_stamp
    #x-amz-copy-source-if-modified-since: time_stamp
    #<request metadata>
    #Authorization: signatureValue
    #Date: date

    return Apache2::Const::DECLINED;
}
1;

