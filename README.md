# PHILIPS_TO_ISMRMRD_EXE
Windows version of philips_to_ismrmrd intended for use on Philips MRI scanners running Windows 7

# INSTALLATION
1. Login into a Philips MR scanner with service/admin privileges
2. Run `install_philips_to_ismrmrd.pl`
3. Reboot for changes to PATH environment variable to take full effect

# USAGE
`philips_to_ismrmrd.pl labrawsin_filename1 [labrawsin_filename2] ... [labrawsin_filenameN]`

* labrawsin filenames can contain .LAB, .RAW, .SIN suffix or no suffix at all
* a complete set of 3 files (.LAB, .RAW, .SIN) must be available for successful conversion, but just one filename/prefix is passed on the command line
* output `.h5` file has the same prefix and is written to same location as input file
* input labrawsin_filename(s) can also be folder names for which all *.SIN files will be found and processed

# WINDOWS EXPLORER SHORTCUT

* Select one or more labrawsin files or folders containing labrawsin files
* Right-click and select `Send to -> philips_to_ismrmrd.pl`

# NOTES

* `philips_to_ismrmrd.pl` uses debug flag to produce `_raw.xml` and `_processed.xml` outputs
* Information in `_raw.xml` can be used to create a custom version of the XML stylesheet `IsmrmrdPhilips.xsl`
* The `IsmrmrdPhilips.xsl` file used by `philips_to_ismrmrd.pl` is located at the installation location, e.g. `G:\Site\ClinicalScience\philips_to_ismrmrd\philips_to_ismrmrd_exe`
* The compiled philips_to_ismrmrd.exe will not run on Windows XP

# SEE ALSO
* [https://github.com/ismrmrd/ismrmrd](https://github.com/ismrmrd/ismrmrd)
* [https://github.com/ismrmrd/philips_to_ismrmrd](https://github.com/ismrmrd/philips_to_ismrmrd)
