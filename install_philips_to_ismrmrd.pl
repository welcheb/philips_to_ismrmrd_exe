#!/Apps_32/perl/bin/perl -w
use oslnm;
use File::Copy;
use Cwd;

#-----------------------------------------------------------------------------
# CONFIGURATION
#-----------------------------------------------------------------------------
$site_clinical_science_directory = "ClinicalScience";
$site_philips_to_ismrmrd_directory = "philips_to_ismrmrd";
@subdirs_to_copy = ('philips_to_ismrmrd_exe');
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Optional Configuration Section
#-----------------------------------------------------------------------------

# character used for horizontal rule
$hr_char = "-";

# DOS  window color scheme is a two digit hex number
# it's nerdy, but it's fun
# 0 = black
# 1 = blue
# 2 = green
# 3 = cyan
# 4 = red
# 6 = magenta
# 9 = Bright Blue
# A = Bright Green
# B = Bright Cyan
# C = Bright Red
# D = Bright Magenta
# E = Yellow
# F = Bright White

# DOS window colors
$dos_color_normal = "0E"; # black background, yellow text
$dos_color_error = "4F";  # red background, white text

# DOS window size
$dos_cols = 120;
$dos_lines = 50;

# recolor and resize the DOS console window
system "color $dos_color_normal";
system "mode con cols=$dos_cols lines=$dos_lines";
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# DETECT/SET DIRECTORY PATHS
#-----------------------------------------------------------------------------
# DETECT GYRO_SITE
$GYRO_SITE = "";
oslnm::translate("GYRO_SITE", $GYRO_SITE);
$GYRO_SITE =~ s/\\/\//g; # replace backward slashes with forward slashes

# DETECT PATH FROM WHICH THE INSTALL IS BEING RUN (SOURCE OF INSTALL FILES)
$install_src_path = getcwd;

# SET INSTALLATION PATH
$install_dst_path = $GYRO_SITE."$site_clinical_science_directory/$site_philips_to_ismrmrd_directory";
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# PRINT INFORMATION BANNER TO SCREEN
#-----------------------------------------------------------------------------
&print_hr;
print "  PHILIPS_TO_ISMRMRD INSTALLATION\n";
&print_hr;
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# # DETECT AND HANDLE RUNNING INSTALL FROM DESTINATION LOCATION
#-----------------------------------------------------------------------------
if( uc($install_src_path) eq uc($install_dst_path) )
{

    print "  ATTENTION!  Installation source and destination path are identical : $install_src_path\n\n"; 
    print "  Only modification to system PATH environment variable will be applied (if necessary).\n\n";

	&add_path_to_philips_to_ismrmrd("$install_dst_path/philips_to_ismrmrd_exe/");
	    
    print "\n  INSTALLATION COMPLETE.\n";
    &press_any_key;
    exit();
}
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# This is the normal case, i.e. no previous installation
#-----------------------------------------------------------------------------
print "  install_src_path = $install_src_path\n";
print "  install_dst_path = $install_dst_path\n";
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# DELETE EXISTING INSTALLATION
#-----------------------------------------------------------------------------
if(-d $install_dst_path)
{
    print "  Existing installation detected. It will be deleted.\n";
    &empty_dir($install_dst_path);
    rmdir($install_dst_path) or &my_die("Cannot delete directory ($install_dst_path) : $!");
}
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# CREATE DIRECTORIES IF NECESSARY
#-----------------------------------------------------------------------------
$dir_to_create = "$GYRO_SITE/$site_clinical_science_directory";
if( !(-d $dir_to_create) )
{
    print "  Creating directory $dir_to_create.\n";
    mkdir($dir_to_create) or &my_die("Cannot create dir ($dir_to_create): $!");
}
$dir_to_create = "$GYRO_SITE/$site_clinical_science_directory/$site_philips_to_ismrmrd_directory";
if( !(-d $dir_to_create) )
{
    print "  Creating directory $dir_to_create.\n";
    mkdir($dir_to_create) or &my_die("Cannot create dir ($dir_to_create): $!");
}
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# COPY INSTALLATION INTO PLACE
#-----------------------------------------------------------------------------
print "  Copying installation into place.\n";
for(@subdirs_to_copy)
{
    print "  Copying $_\n";
    &copy_dir("$install_src_path/$_","$install_dst_path");
}
&copy_files("$install_src_path","$install_dst_path");
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# UPDATE PATH
#-----------------------------------------------------------------------------
&add_path_to_philips_to_ismrmrd("$install_dst_path/philips_to_ismrmrd_exe/");
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# EXIT
#-----------------------------------------------------------------------------
exit();
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# HELPER SUBROUTINES
#-----------------------------------------------------------------------------
sub press_any_key
{
    print "\n";
    system "pause";
}

sub print_hr
{
    print "  ";
    for(my $k=0;$k<($dos_cols-4);$k++) { print $hr_char; }
    print "\n";
}

sub my_die($)
{
    system "color $dos_color_error";
    print "  ERROR : $_[0]\n";
    &press_any_key;
    die;
}

sub copy_dir($$)
{
    my $dir_to_copy = $_[0];
    my $dst = $_[1];
    my $dir_to_copy_basename = "";
    my $dir_to_create = "";
    my $filename = "";
    my $k = 0;
    
    if($dir_to_copy =~ /(.+)([\\\/])(.+)/)
    {
        $dir_to_copy_basename = $3;
        $dir_to_create = "$dst/$dir_to_copy_basename";
        mkdir($dir_to_create) or &my_die("Cannot create dir ($dir_to_create): $!");
    }
    else
    {
        &my_die("Cannot determine directory basename in path ($dir_to_copy)\n");
    }
    
    opendir DIR, $dir_to_copy or &my_die("Cannot open directory to copy ($dir_to_copy): $!\n");
    my @dir_contents = readdir(DIR);
    closedir DIR;
    
    my @files_to_copy = grep { (! /^\./) && (-f "$dir_to_copy/$_") } @dir_contents;
    my @dirs_to_copy  = grep { (! /^\./) && (-d "$dir_to_copy/$_") } @dir_contents;
    
    # copy directores
    for($k=0;$k<=$#dirs_to_copy;$k++)
    {
        my $src2 = "$dir_to_copy/$dirs_to_copy[$k]";
        my $dst2 = $dir_to_create;
        &copy_dir($src2,$dst2);
    }
    
    # copy files
    for($k=0;$k<=$#files_to_copy;$k++)
    {
        $filename = "$dir_to_copy/$files_to_copy[$k]";
        copy($filename,$dir_to_create) or &my_die("Cannot copy filename ($filename) to destination ($dir_to_create): $!");
    }
}

sub copy_files($$)
{
    my $dir_to_copy = $_[0];
    my $dst = $_[1];
    
    print "  ....copy_files: copy $dir_to_copy to $dst\n";
    opendir DIR, $dir_to_copy or &my_die("Cannot open directory to copy ($dir_to_copy): $!\n");
    my @dir_contents = readdir(DIR);
    closedir DIR;
    
    my @files_to_copy = grep { (! /^\./) && (-f "$dir_to_copy/$_") } @dir_contents;
    # copy files
    for(my $k=0;$k<=$#files_to_copy;$k++)
    {
        my $filename = "$dir_to_copy/$files_to_copy[$k]";
        copy($filename,$dst) or &my_die("Cannot copy filename ($filename) to destination ($dir_to_create): $!");
    }
}

sub empty_dir($)
{
    my $dir_to_empty = $_[0];
    my $dirname = "";
    my $filename = "";
    my $k = 0;
    
    opendir DIR, $dir_to_empty or &my_die("Cannot open directory to empty ($dir_to_empty): $!\n");
    my @dir_contents = readdir(DIR);
    closedir DIR;
    
    my @files_to_delete = grep { (! /^\./) && (-f "$dir_to_empty/$_") } @dir_contents;
    my @dirs_to_delete  = grep { (! /^\.+$/) && (-d "$dir_to_empty/$_") } @dir_contents;
    
    for($k=0;$k<=$#dirs_to_delete;$k++)
    {
        $dirname = "$dir_to_empty/$dirs_to_delete[$k]";
        &empty_dir("$dirname");
        rmdir($dirname) or &my_die("Cannot delete directory ($dirname) : $!");
    }
    
    for($k=0;$k<=$#files_to_delete;$k++)
    {
        $filename = "$dir_to_empty/$files_to_delete[$k]";
        unlink($filename) or &my_die("Cannot delete filename ($filename) : $!");
    }
}

sub add_path_to_philips_to_ismrmrd($)
{
	my $path_to_philips_to_ismrmrd = $_[0];
	
	print "Checking for path to philips_to_ismrmrd in System PATH environment variable\n";

	if( $ENV{"PATH"} =~ m/\Q$path_to_philips_to_ismrmrd\E\\?(;|$)/i )
	{
		print "Path to philips_to_ismrmrd already in the the System PATH environment variable.  No changees made.\n";
	}
	else
	{
		print "Path to philips_to_ismrmrd NOT found in the the System PATH environment variable.  Adding now...\n";
		my $reg_add_command = "reg add \"HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\" /v Path /t REG_EXPAND_SZ /d \"%Path%;$path_to_philips_to_ismrmrd\" /f";
		print "\nreg_add_command = $reg_add_command\n\n";
		system($reg_add_command);
		print "\n*** Changes to System PATH will not fully take effect until the system is rebooted. ***\n\n";
	}
}
#-----------------------------------------------------------------------------