#!/usr/bin/perl
package shbot;
use base qw(Net::Server);
use warnings;
use WWW::Mechanize;
use strict;
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows IE 6' );
sub runtimer {
	if ($mech->content =~ /if \(i\d+<=\((\d+)\)/) { 
		print "TIMER $1" . "\n";
		sleep($1);
	} else { return 0; }
	if ($mech->content =~ /(WorkForm\d+)/) { 
		$mech->submit_form( form_name =>  $1 );
	} else { return 0; }
	return 1;
}

sub crep {
	my $captret = shift;
                $mech->submit_form(
                        form_number => 2,
                        fields    => {
                                            nummer  => $captret
                                     },
                 );
}


sub captcha {
	if ($mech->content( format => "text" ) =~ /repeat the numbers/) {
		$mech->get ("http://www.slavehack.com/workimage.php");
		print "CAPTCHA\n"; # . $mech->content; removed for testing, since client is _not_ working yet.
		$mech->save_content ("workimage.png");
 		system ("display workimage.png");
		$mech->back;
	}
}

sub login {
	$mech->get ( "http://www.slavehack.com/index.php" );
	$mech->submit_form(
	    form_number => 1,
	    fields    => { 
				login  => shift, 
				loginpas => shift
	                 },
	);
	captcha();
	if ($mech->content( format => "text" ) =~ /My computer password/) { return 1; }
	else { return 0; }
}

sub loginslave {
	my $iptologin = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptologin&action=login" );
	$mech->submit_form( form_number => 2 );
}
sub getslaves {
	$mech->get( 'http://www.slavehack.com/index2.php?page=slaves' );
	captcha();
	my $toret;
	foreach ($mech->content( format => "text" ) =~ m/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/g) { 
		$toret = $toret . " " . $_;
	}
	return $toret;
}

sub crackip {
	my $iptocrack = shift;
	$mech->get( "http://www.slavehack.com/index2.php?gow=$iptocrack&page=internet&action=crack" );
	captcha();
	runtimer();
}

sub clear_logs {
	my $iptoclear = shift;
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoclear&action=log" );
        captcha();
        $mech->submit_form(
                form_number => 2,
                fields => {
                                logedit => '',
                                poster => 1
                                },
        );
        runtimer();
}

sub clear_logs_ip {
	my $iptoclear = shift;
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoclear&action=log" );
        captcha();
        my ($curip, $logtext);
        if ($mech->content =~ m/\[m/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/g]/) { $curip = $1; }
	if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) { $logtext = $1; }
        $logtext =~ s/$curip//g;
        $mech->submit_form(
                form_number => 2,
                fields => {
                                logedit => $logtext,
                                poster => 1
                                },
        );
        runtimer();
}

sub clear_local_logs {
	$mech->get( 'http://www.slavehack.com/index2.php?page=logs' );
	captcha();
	$mech->submit_form(
		form_number => 1,
		fields => {
				logedit => '',
				poster => 1
				},
	);
	runtimer();
}

sub extract_logs {
	my $iptoextract = shift;
	print "Extracting logs from $iptoextract\n";
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoextract&action=log" );
	captcha();
	my $toret;
	if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
		foreach ($1 =~ m/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/g) {
			$toret = $toret . " " . $_;
		}
	}
	return $toret;
}

sub extract_logs_bank {
        my $iptoextract = shift;
        print "Extracting logs from $iptoextract\n";
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoextract&action=log" );
        captcha();
	my $toret;
        if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
                foreach ($1 =~ m/(\d{6})/g) {
                        $toret = $toret . " " . $_;
                }
        }
	return $toret;
}

sub upl_list {
	my $iptoupl = shift;
	$mech->get ( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoupl&action=files&aktie=upload" );
	captcha();
	my $uplform = $mech->form_number(2);
	my $inp = $uplform->find_input("upload");
	my @sw = $inp->value_names;
	my @ids = $inp->possible_values;
	my $iter = 0;
	my $toret;
	foreach (@ids) { $toret = $toret . $ids[$iter] . ":" . $sw[$iter] . ","; $iter++; }
	return $toret;
}

sub upload {
	my $iptoupl = shift;
	my $idtoupl = shift;
	$mech->get ( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoupl&action=files&aktie=upload" );
	captcha();
	$mech->submit_form(form_number => 2, fields => { upload  => $idtoupl, });
	runtimer();
}

sub virinstlist {
	my $iptoinst = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoinst&action=files" );
	my $toret;
        foreach ($mech->content =~ m/a href=index2.php\?page=internet&gow=.*&action=files&aktie=install&virus=(\d*)/g) {
        	$toret = $toret . " " . $_;
	}
	return $toret;
}

sub virinst {
	my $iptoinst = shift;
	my $idtoinst = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoinst&action=files&aktie=install&virus=$idtoinst" );
	runtimer();
	return 1;
}


sub avlist {
	my $iptoinst = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoinst&action=files" );
	my $toret;
        foreach ($mech->content =~ m/a href=index2.php\?page=internet&gow=.*&action=files&aktie=scan&scan=(\d*)/g) {
        	$toret = $toret . " " . $_;
	}
	return $toret;
}

sub runav {
	my $iptoinst = shift;
	my $idtoinst = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoinst&action=files&aktie=scan&scan=$idtoinst" );
	runtimer();	
	return 1;
}

sub process_request {
     my $self = shift;
     while (<STDIN>) {
#     	print STDOUT "REC'd" . $_ . "\n";
     	chomp;
	my @command = split(/ /, $_);
	if ($command[0] eq "LOGIN") { print "RETURN " . login($command[1], $command[2]). "\n"; }
	elsif ($command[0] eq "CAPRET") { crep($command[1]); } 
	elsif ($command[0] eq "GETSLAVES") { print "RETURN " . getslaves() . "\n"; } 
	elsif ($command[0] eq "LOGINSLAVE") { loginslave($command[1]); print "RETURN 1\n"; }
	elsif ($command[0] eq "CRACKIP") { crackip($command[1]); print "RETURN 1\n"; } 
        elsif ($command[0] eq "EXTRACT_LOGS") { print "RETURN " . extract_logs($command[1]) . "\n"; }
	elsif ($command[0] eq "EXTRACT_LOGS_BANK") { print "RETURN " . extract_logs_bank($command[1]) . "\n"; }
	elsif ($command[0] eq "CLEAR_LOGS") { clear_logs($command[1]); print "RETURN 1\n";}
	elsif ($command[0] eq "CLEAR_LOGS_IP") { clear_logs_ip($command[1]);}
	elsif ($command[0] eq "CLEAR_LOCAL_LOGS") { clear_local_logs(); print "RETURN 1\n"; }
	elsif ($command[0] eq "UPL_LIST") { print "RETURN " . upl_list($command[1]) . "\n"; }
	elsif ($command[0] eq "VIR_INST_LIST") { print "RETURN " . virinstlist($command[1]) . "\n"; }
	elsif ($command[0] eq "VIR_INST") { print "RETURN " . virinst($command[1], $command[2]) . "\n"; }
	elsif ($command[0] eq "AV_LIST") { print "RETURN " . avlist($command[1]) . "\n"; }
	elsif ($command[0] eq "AV_RUN") { print "RETURN " . runav($command[1], $command[2]) . "\n"; }
	elsif ($command[0] eq "UPLOAD") { upload($command[1], $command[2]); print "RETURN 1\n";}
	else { print "RETURN 0\n" } 
        last if /QUIT/i; # Drop connection on QUIT
}
}
shbot->run(port => 9988);
