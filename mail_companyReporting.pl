#!/cygdrive/c/Perl/bin/perl
##!/usr/local/bin/perl

use strict;
use File::Basename;
use File::Spec;
use File::Path qw(mkpath);
use Date::Calc qw(Add_Delta_Days Delta_Days Today);
use MIME::Lite;

(my $absFile = File::Spec->rel2abs(__FILE__)) =~ s/\\/\//go;
(my $baseDir = $absFile) =~ s/\/[^\/]*\/[^\/]*$//o;
(my $tmpPath = $baseDir) =~ s/$/\/reports\/mail/o;
mkpath "$baseDir\/reports";
mkdir $tmpPath or die "Another instance running";
mailfolder() foreach(sort <$baseDir/reports/2[0-9][0-9][0-9]/2[0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]>);
rmdir $tmpPath;

sub mailfolder {
	my $folder = $_;
	printf "Mailing folder $folder \n";
	mailpdf() foreach (sort <$folder/*.pdf>);
	mailcsv() foreach (sort <$folder/*.csv>);
	rename $folder, "$folder.mailed";
}
	
sub mailpdf {
	my $file = $_;
	(my $subject = basename($file)) =~ s/Daily_/Daily /o;
	mail($subject, $file, 'application/pdf');
}

sub mailcsv {
	my $file = $_;
	(my $zip = $file) =~ s/\.csv$/.csv.zip/o;
	`zip -j $zip $file`;
	(my $subject = basename($file)) =~ s/Daily_/Daily /o;
#	mail($subject, $zip, 'application/zip'); # per My Boss: "deliver ... reports that come as zips ... as csv"
	mail($subject, $file, 'text/csv');
	unlink $file;
}

sub mail {
	my ($subject, $file, $type) = @_;
	my @rcpts = ( 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com'	);
#	my @rcpts = ( 'anytime@anyplace.com', 'anytime@anyplace.com' );
#	my @rcpts = ( 'anytime@anyplace.com', 'anytime@anyplace.com' );
	#my @rcpts = ( 'anytime@anyplace.com', 'anytime@anyplace.com', 'anytime@anyplace.com' );
	#my @rcpts = ( 'anytime@anyplace.com' );
	#@rcpts = ( 'anytime@anyplace.com' );
	mailtorcpt($subject, $file, $type, $_) foreach @rcpts;
}

sub mailtorcpt {
	my ($subject, $file, $type, $rcpt) = @_;
	my $msg = MIME::Lite->new(
		From => 'anytime@anyplace.com',
        To => $rcpt,
        Subject => $subject,
        Type => 'TEXT',
        Data => ''
    );

    $msg->attach(
        Type => $type,
        Path => $file,
        Filename => basename($file)
    );
	
    $msg->send('smtp','outgoing.anycorp.net');
}
