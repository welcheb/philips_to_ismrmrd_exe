#!/Apps_32/perl/bin/perl -w

use File::Basename;
use File::Glob qw(:globally :nocase);

#-----------------------------------------------------------------------------
# PERL script wrapper for philips_to_ismrmrd.exe
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# DETECT LOCATION OF INSTALLED IsmrmrdPhilips.xsl
#-----------------------------------------------------------------------------
my $path_to_philips_to_ismrmrd_exe = dirname(`where philips_to_ismrmrd.exe`);
$path_to_philips_to_ismrmrd_exe =~ s/\//\\/g; # replace forward slashes with backward slashes
#print "$path_to_philips_to_ismrmrd_exe\n";
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# DEFAULT ARGUMENTS
#-----------------------------------------------------------------------------
$arg_pMapStyle = "$path_to_philips_to_ismrmrd_exe\\IsmrmrdPhilips.xsl";
$arg_debug = "1";
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# PROCESS INPUTS
#-----------------------------------------------------------------------------
my $nr_files = 0;
my @inputs = ();
for($k=0;$k<=$#ARGV;$k++)
{
  if(-d $ARGV[$k]) # input is a directory
  {
    my $sin_folder = $ARGV[$k];
    $sin_folder =~ s/\//\\/g; # replace forward slashes with backward slashes
    my @sinfiles = <$sin_folder\\*.SIN>;
    foreach $sinfile (@sinfiles)
    {
        if(-f $sinfile)
        {
            print "Found $sinfile\n";
            $inputs[$nr_files] = $sinfile;
            $nr_files++;
        }
    }
    
  }
  else
  {
    if(-f $ARGV[$k])
    {
        print "Found $ARGV[$k]\n";
        $inputs[$nr_files] = $ARGV[$k];
        $nr_files++;
    }
  }
}

if($nr_files<1)
{
	print "USAGE: philips_to_ismrmrd.pl labrawsin_filename1 [labrawsin_filename2] ... [labrawsin_filenameN]";
}
else
{
	my @labrawsin_suffixlist = ('.lab','.raw','.sin');
	foreach(@inputs)
	{
		my ($input_name, $input_path, $input_suffix) = fileparse($_, @labrawsin_suffixlist);
		$input_path =~ s/\//\\/g; # replace forward slashes with backward slashes
		#print  "  converting (input_name, input_path, input_suffix) = ($input_name, $input_path, $input_suffix)\n";
		
		# remove any raw.xml or processed.xml
		if (-f "raw.xml")
		{
			#print  "deleting raw.xml\n";
			unlink("raw.xml");
		}
		
		if (-f "processed.xml")
		{
			#print  "deleting processed.xml\n";
			unlink("processed.xml");
		}

		# converter will keep appending to output_file_fullname if it already exists
		# so make sure output output_file_fullname does not exist	
		my $output_file_fullname = "\"$input_path\\$input_name.h5\"";
		#print  "output_file_fullname = $output_file_fullname\n";
		my $system_output = `del $output_file_fullname 2>nul`;

		# call philips_to_ismrmrd.exe
		system("philips_to_ismrmrd.exe --debug $arg_debug --pMapStyle \"$arg_pMapStyle\" -o $output_file_fullname -f \"$input_path\\$input_name\"");
		
		# rename raw.xml and process.xml if they are present
		if(-f "raw.xml")
		{
			my $raw_filename = "\"$input_path\\$input_name"."_raw.xml\"";
			my $system_output = `move raw.xml $raw_filename`;
		}
		
		if(-f "processed.xml")
		{
			my $processed_filename = "\"$input_path\\$input_name"."_processed.xml\"";
			my $system_output = `move processed.xml $processed_filename`;
		}
	}
}
#-----------------------------------------------------------------------------
