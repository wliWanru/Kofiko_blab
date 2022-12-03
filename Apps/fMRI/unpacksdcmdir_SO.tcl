
#------------------------------------------------------------------#
proc PrintUsage { } {
  puts "USAGE: upacksdcmdir "
  puts ""
  puts "  -src  srcdir  : directory with the DICOM files "
  puts "  -targ targdir : top directory into which the files will be unpacked"
  puts ""
  puts "  -run  runno subdir format name : spec unpacking rules on cmdline"
  puts "  -cfg  file : spec unpacking rules in file"
  puts "  -seqcfg seqcfgfile : spec unpacking rules based on sequence"
  puts ""
  puts "  -fsfast  : unpack to fsfast  directory structure"
  puts "  -generic : unpack to generic directory structure"
  puts "  -noinfodump : do not create infodump file"
  puts "  -sphinx  : unpack and also correct for sphinx position"
  puts ""
  puts "  -scanonly file : only scan the directory and put result in file"
  puts "  -log file : explicilty set log file"
  puts "  -nspmzeropad N : set frame number zero padding width for SPM"
  puts "  -no-unpackerr     : do not try to unpack runs with errors"
  puts ""
  puts "  -help : print out information about how to run this program"
  puts ""
}
#------------------------------------------------------------------#
proc HelpExit { } {
puts ""
PrintUsage;
puts ""

puts "DESCRIPTION"
puts ""
puts "This program will unpack the data from a directory containing Siemens"
puts "DICOM files. Unpacking can entail copying DICOM files into directories"
puts "sorted by series/run or converting them into a different format (also"
puts "sorted by series/run). It is assumed that the source directory contains"
puts "the files from one and only one scanning session. Supported formats are"
puts "DICOM, COR, bshort, MINC, analyze, SPM-analyze, NIFTI, MGH, and MGZ"
puts "Note: this program does not convert properly to MINC."
puts ""
puts "ARGUMENTS:"
puts ""
puts "  -src srcdir "
puts ""
puts "     This is the directory where the DICOM files reside. This can be "
puts "     a subdirectory on a CD-ROM. Note that there is often a file called"
puts "     'dicomdir.' This should not be confused with the directory where "
puts "     the puts DICOM files are located."
puts ""
puts "  -targ trgdir "
puts ""
puts "     This is the parent directory into which the files will be unpacked."
puts "     It does not need to exist before running this script. The sorting "
puts "     of the files into directories under the parent is determined by "
puts "     the unpacking rules (see below)."
puts ""
puts "  -run RunNumber Subdir Format Name"
puts ""
puts "     Specifies unpacking rules from the command-line."
puts ""
puts "  -cfgfile file"
puts ""
puts "     Specifies unpacking rules using the given file."
puts ""
puts "  -seqcfg file"
puts "
      Specifies unpacking rules based on the acquisition pulse
      sequence/protocol name (DICOM tag 0x18, 0x1030). This may be more 
      convenient than run-based. See SPECIFYING UNPACKING RULES below.
      Note: the protocol name listed in the seqcfgfile cannot have white
      spaces (see BUGS below). "
puts ""
puts "  -fsfast"
puts ""
puts "     Sort into FS-FAST directory structure."
puts ""
puts "  -generic "
puts ""
puts "     Sort generically."
puts ""
puts "  -nspmzeropad N"
puts ""
puts "     Set the zero-padding of the frame number for spm-analyze files. Default"
puts "     is 3. SPM files will have names of the following format NameXXX.img, where"
puts "     XXX is the zero-padded frame number."
puts ""
puts "  -scanonly file"
puts ""
puts "     This instructs the script to only scan the directory to determine"
puts "     the contents. A summary of the contents are stored in file. This"
puts "     can be useful for specifying the unpacking rules and for checking"
puts "     the error status of each run. It is not necessary to specify "
puts "     unpacking rules (though source and target directories are still"
puts "     necessary)."
puts ""
puts "  -log logfile"
puts ""
puts "     Explicitly set log file"
puts ""
puts "  -no-unpackerr"
puts ""
puts "     Do not try to unpack a run if the error flag is set."
puts ""
puts ""
puts "SPECIFYING UNPACKING RULES:"
puts "
To unpack a series/run of data, one needs to specify three things: 
   1. The subdirectory the data will go into
   2. The name assigned to the data file(s)
   3. The format

This is done by specifying a configuration and sorting method. The
sorting method can be either generic or fsfast. The configuration can
be either run-based or pulse sequence-based. The final path of a data file
can be determined from the following table:

  Generic, Run-based: targdir/subdir/name.ext
  Generic, Seq-based: targdir/subdir/nameXXX.ext
  FSFAST,  Run-based: targdir/subdir/XXX/name.ext
  FSFAST,  Seq-based: targdir/subdir/XXX/name.ext

where XXX is the three digit, zero-padded run number. ext is the
format-based extension.

The run-based configuration can be specified either on the command
line (-run option) or from a file (-cfg option). In either case, the
configuration is consists of four pieces of information: run number,
subdir, format, and name. The run number is the integer number of the
run (or Series) to be unpacked. Only the runs specified will be
unpacked.

The pulse sequence-based configuration can only be specified from a
file. Each row in the file must contain the following four pieces of
information: protocol/sequence name, subdirectory, format, name.  The
protocol name is that stored in DICOM tag 0x18 0x1030. If a protocol
in the source directory does not match one in the configuration file,
the protocol is skipped.  If generic sorting is used, then the
three digit run number is inserted between the name and
extension. This method is convenient when unpacking many different
sessions where the sequences are all the same but the run on which
each was collected may change. A configuration file with sequences
commonly used around the MGH/NMR center can be found in
\$FREESURFER_HOME/numaris4-protocols.unpackcfg."

puts ""
puts "Legal formats are:"
puts ""
puts "     DICOM   - just copies DICOM files"
puts "     COR     - MGH-NMR COR file format"
puts "     bshort  - MGH-NMR bshort file format"
puts "     MINC    - MNI Medical Imaging NetCDF format"
puts "       NOTE: does not convert properly to MINC yet"
puts "     SPM     - SPM (Analyze 3D) format"
puts "     ANALYZE - Full Analyze 4D format"
puts "     NII     - NIFTI1 (.nii)"
puts "     MGH     - Local MGH format"
puts "     MGZ     - Local MGH format (compressed)"
puts ""
puts "Case is ignored. For DICOM and COR formats,"
puts "the Name is ignored (though there must be a placeholder there). For bshort, "
puts "the Name becomes the stem. For FS-FAST applications, it is strongly suggested"
puts "that the Name for bshorts be set to 'f' (no quotes). When SPM format is "
puts "chosen, the actual file name will be NameXXX.img, where XXX is the three-"
puts "digit, zero-padded frame number (starting with 1). The width of the zero-"
puts "padding can be set with -nspmzeropad option. For ANALYZE, Name.img and Name.hdr"
puts "will be created. MGH must have a .mgh extension, MGZ must have a .mgz extension,"
puts "and NII must have a .nii extension."
puts ""
puts "The unpacking configuration can be specified either on the"
puts "command-line (with the -run flag) or in a file (with the -cfg flag),"
puts "but not both. If using the command-line option, multiple runs can be"
puts "can be specified with multiple -run flags. If using a configuration"
puts "file, specify all runs inside the file. The configuration file has a"
puts "row for each run. Each run has four columns separated by 'white' space"
puts "(ie, spaces or tabs). The information in each row is the same as that"
puts "specified with -run."
puts ""
puts "SCANNING A DICOM DIRECTORY"
puts ""
puts "When the -scanonly option is used, unpacksmincdir will scan the source"
puts "directory for all the Siemens DICOM files. It will also sort them into"
puts "Run/Series and make sure that each Run is complete. The summary will"
puts "be put into file specified as the argument to -scanonly. This can be"
puts "useful for determining the unpacking rules.  The output of scanonly looks "
puts "something like below:"
puts ""
puts "  1            localizer  ok  512 512   3   1 6142643"
puts "  2        SagMPRAGE8Min  ok  256 192 160   1 6142657"
puts "  3        SagMPRAGE4Min  ok  256 256  60   1 6142077"
puts "  4        SagMPRAGE8Min  ok  256 192 160   1 6140088"
puts "  5        T1ep2dHighRes  ok  256 256  21   1 6139499"
puts "  6      T2TSEAxialHiRes  ok  512 448  21   1 6136953"
puts "  7      ep2d_mosaic_mgh  ok   64  64  21 172 6137247"
puts "  8      ep2d_mosaic_mgh  ok   64  64  21 172 6136826"
puts "  9      ep2d_mosaic_mgh err   64  64  21   2 6133576"
puts " 10      ep2d_mosaic_mgh  ok   64  64  21 196 6133604"
puts " 11      ep2d_mosaic_mgh  ok   64  64  21 196 6130701"
puts " 12      T2TSEAxialHiRes  ok  512 512  21   1 6128022"
puts ""
puts "The columns have the following interpretation: run/series number,"
puts "protocol, error status, number of columns, number of rows, number of"
puts "slices, number of frames, and DICOM file. The error status is either"
puts "'err' or 'ok'. The status is set to 'err' if the run appears to be"
puts "incomplete for some reason (probably aborted). The DICOM file is the"
puts "first file found in the series (mainly good for debugging). "
puts ""
puts "EXAMPLES"
puts ""
puts "Consider a session consisting of the data collected above sitting "
puts "in a directory called /space/dicomdir"
puts ""
puts "1. Copy the localizer DICOM files to /space/mydata/scout"
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata -generic"
puts "    -run 1 scout DICOM blah "
puts ""
puts "  Note: 'blah' is ignored because the format is DICOM."
puts ""
puts "2. Convert the t1epi and the second functional to bshort using "
puts "   FS-FAST sorting"
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata -fsfast"
puts "    -run 5 t1epi bshort f "
puts "    -run 8 bold  bshort f "
puts ""
puts "  This will create /space/mydata/t1epi/005 and /space/mydata/bold/008,"
puts "  each with bshort volumes."
puts ""
puts "3. Convert the MP-RAGES to COR, and the t2 conventional and all the"
puts "   functionals (except run 9) to bshort using FS-FAST sorting and "
puts "   a configuration file."
puts ""
puts "   Create a configuration file (eg, mycfgfile) with the contents"
puts ""
puts "         2 3danat COR    blah"
puts "         3 3danat COR    blah"
puts "         4 3danat COR    blah"
puts "         6 t2conv bshort f "
puts "         7 bold   bshort f "
puts "         8 bold   bshort f "
puts "        10 bold   bshort f "
puts "        11 bold   bshort f "
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata "
puts "    -fsfast -cfg mycfgfile"
puts ""
puts "  This will create 3danat/002, 3danat/003, 3danat/004 (each with COR"
puts "  volumes), t2conv/006, bold/007, bold/008, bold/010, bold/011"
puts "  (each as bshort volumes with stem f)."
puts ""
puts "4. Convert the MP-RAGES to MINC using generic sorting"
puts ""
puts "   Create a configuration file (eg, mycfgfile) with the contents"
puts ""
puts "         2 Sag8Min MINC   MPRAGE1.mnc"
puts "         3 Sag4Min MINC   MPRAGE1.mnc"
puts "         4 Sag8Min MINC   MPRAGE2.mnc"
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata "
puts "    -generic -cfg mycfgfile"
puts ""
puts "  This will create /space/mydata/Sag8Min/MPAGE1.mnc and MPAGE2.mnc, and "
puts "  /space/mydata/Sag4Min/MPAGE1.mnc. Note that the files that go in Sag8Min"
puts "  must have different names or else one will overwrite the other."
puts ""
puts "5. Convert the functionals to spm-analyze format using generic sorting. Set"
puts "   the frame number zero padding width to 4."
puts ""
puts "   Create a configuration file (eg, mycfgfile) with the contents"
puts ""
puts "         7 bold  SPM  f-ep2d-07- "
puts "         8 bold  SPM  f-ep2d-08- "
puts "        10 bold  SPM  f-ep2d-10- "
puts "        11 bold  SPM  f-ep2d-11- "
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata "
puts "    -generic -cfg mycfgfile -nspmzeropad 4"
puts ""
puts "  This will create directory /space/mydata/bold/ in which there will be"
puts "  four volumes. The first volume will have 172 files, each corresponding"
puts "  to a frame. The files in the series will be f-ep2d-07-0001.img,"
puts "  f-ep2d-07-0002.img, ... f-ep2d-07-0172.img, etc."
puts ""
puts "6. Convert the first anatomical and first functional to Analyze 4D format"
puts "   using generic sorting."
puts ""
puts "   Create a configuration file (eg, mycfgfile) with the contents"
puts ""
puts "         2 Sag8Min MINC   MPRAGE1"
puts "         7 bold  ANALYZE  f-ep2d-07"
puts ""
puts "  unpacksdcmdir -src /space/dicomdir -targ /space/mydata "
puts "    -generic -cfg mycfgfile "
puts ""
puts "  This will create directory /space/mydata/bold/ in which there will be"
puts "  eight files: MPRAGE1.img, MPRAGE1.hdr, MPRAGE1.mat, f-ep2d-07.img,"
puts "  f-ep2d-07.hdr, and f-ep2d-07.mat."
puts ""
puts "7. Same as 6 but use MGZ and NIFTI formats:"
puts ""
puts "   Create a configuration file with the contents"
puts ""
puts "         2 Sag8Min MGZ    mpgrage1.mgz"
puts "         7 bold    NII    f-ep2d-07.nii"
puts ""
puts "OTHER OUTPUT"
puts ""
puts "A file called unpack.log is created in the target directory. This is"
puts "useful for debugging and generally keeping track of where the data came"
puts "from and how it was unpacked."
puts ""
puts "A file called dicomdir.sumfile is created in the target directory."
puts "Each file from the DICOM directory is listed in file along with"
puts "various parameters associated with each file. "
puts ""
puts "In each output directory there will be a file called Name-infodump.dat."
puts "This is a dump of information for one of the files in the series."
puts "This is automatically created with -fsfast. For -generic, the user must"
puts "add -infodump to the command-line."
puts ""
puts "BUGS"
puts ""
puts "This is not guaranteed to work on all Siemens DICOM files. The DICOM "
puts "files must adhere to certain rules. It is incumbent upon the pulse"
puts "sequence programmer to assure that the output files conform to this"
puts "standard. For more information, send email to:  "
puts "             analysis-bugs@nmr.mgh.harvard.edu."
puts ""
puts "Fails on supermosiacs."
puts ""
puts "Does not compute the TR properly if there is a temporal gap between"
puts "volumes."
puts ""
puts "MINC volumes are incorrectly oriented."
puts ""
puts "The protocol names in the DICOM files (tag 18,1030) may have white"
puts "spaces in them. If this is the case, the white spaces are stripped"
puts "before the protocol name is compared to the protocol names found in"
puts "the sequence configuration file. Therefore, when creating the "
puts "sequence configuration file, make sure to strip all the white spaces"
puts "from the protocol names."
puts ""
puts "BUG REPORTING"
puts ""
puts "Send bugs/suggestions to analysis-bugs@nmr.mgh.harvard.edu. For bug"
puts "reports, include the command-line used, the unpack.log file, "
puts "the dicomdir.sumfile, and the config file (if used)."
puts ""
puts "AUTHOR"
puts ""
puts "Douglas N. Greve, Ph.D., MGH-NMR Center"
puts ""
puts "VERSION"
puts ""
puts {$Id: unpacksdcmdir,v 1.19.2.2 2008/03/11 19:56:38 nicks Exp $}

exit 1;

}

#------------------------------------------------------------------#
proc ParseCommandLine { argc argv } {
  global dicomdir targdir sortmethod cfgfile unpackcfg noexec scanonly;
  global scanfile nspmzeropad seqcfgfile unpackerr DoInfoDump Sphinx;
  global LogFile, SkipMoCo;

  set ntharg 0
  while  { $ntharg < $argc } {

    set option [lindex $argv $ntharg];
    incr ntharg 1

    set nargrem [expr $argc - $ntharg]; # number or arguments remaining

    switch -exact -- $option {

      -src {
        if { $nargrem < 1 } { ArgNError $option 1 }
        set dicomdir [lindex $argv $ntharg];
        incr ntharg 1
      }

      -targ {
        if { $nargrem < 1 } { ArgNError $option 1 }
        set targdir [lindex $argv $ntharg];
        incr ntharg 1
      }

      -run {
        if { $nargrem < 4 } { ArgNError $option 4 }
        set runno      [lindex $argv $ntharg]; incr ntharg 1
        set dirid      [lindex $argv $ntharg]; incr ntharg 1
        set unpackfmt  [lindex $argv $ntharg]; incr ntharg 1
        set unpackname [lindex $argv $ntharg]; incr ntharg 1
        set cfg [list $runno $dirid $unpackfmt $unpackname]
        lappend unpackcfg $cfg;
      }

      -cfg {
        if { $nargrem < 1 } { ArgNError $option 1 }
        set cfgfile [lindex $argv $ntharg];
        incr ntharg 1
      }

  
      -seqcfg {
        if { $nargrem < 1 } { ArgNError $option 1 }
        set seqcfgfile [lindex $argv $ntharg];
        incr ntharg 1
      }

      -log {
        if { $nargrem < 1 } { ArgNError $option 1 }
        set LogFile [lindex $argv $ntharg];
        incr ntharg 1
      }

      -scanonly { 
        if { $nargrem < 1 } { ArgNError $option 1 }
        set scanfile [lindex $argv $ntharg];
        set scanonly 1; 
        incr ntharg 1
      }

      -nspmzeropad { 
        if { $nargrem < 1 } { ArgNError $option 1 }
        set nspmzeropad [lindex $argv $ntharg];
        incr ntharg 1
      }

      -fsfast     { set sortmethod fsfast; }
      -sphinx     { set Sphinx 1;}
      -generic    { set sortmethod generic; }
      -infodump   { set DoInfoDump 1; }
      -noinfodump { set DoInfoDump 0; }
      -skip-moco     { set SkipMoCo 1; }
      -no-skip-moco  { set SkipMoCo 0; }
      -unpackerr    { set unpackerr 1; }
      -no-unpackerr { set unpackerr 0; }
      -noexec     { set noexec 1; }
      -help       { HelpExit;} 

      default { 
        puts "ERROR: $option unrecognized";
        exit 1;
      }
    }; # end switch
  }; # end while
  return;
}
#------------------------------------------------------------------#
proc CheckArgs { } {
  global dicomdir targdir sortmethod cfgfile unpackcfg scanonly;
  global scanfile seqcfgfile;

  if { ! [info exists dicomdir] } {
     puts "ERROR: no source directory specified"
     exit 1;
  }

  if { ! [info exists targdir] } {
     puts "ERROR: no target directory specified"
     exit 1;
  }

  if { $scanonly } { return };

  if { [info exists cfgfile] && [info exists unpackcfg] } {
     puts "ERROR: cannot spec cfgfile and command line config"
     exit 1;
  }

  if { ![info exists cfgfile] && ![info exists unpackcfg] && ![info exists seqcfgfile] } {
     puts "ERROR: no unpacking rules specified"
     # Goto GUI here???
     exit 1;
  }

  if { [info exists cfgfile] && [info exists seqcfgfile] } {
     puts "ERROR: cannot spec cfgfile and seqcfgfile"
     exit 1;
  }

  if { [info exists cfgfile] } {
    if {! [file exists $cfgfile]} {
      puts stdout "ERROR: config file $cfgfile does not exist"
      exit 1;
    }
    set unpackcfg [ReadUnpackCfg $cfgfile];
  }; # else unpackcfg specified on command line

  if { [info exists seqcfgfile] } {
    if {! [file exists $seqcfgfile]} {
      puts stdout "ERROR: config file $seqcfgfile does not exist"
      exit 1;
    }
  }; 
  return;
}
#---------------------------------------------------------------#
proc ReadSeqCfg { seqcfgfile } {
  global LF;

  if [catch {open $seqcfgfile r} FileId] {
     puts "Cannot open $seqcfgfile";
     puts $LF "Cannot open $seqcfgfile";
     exit 1;
  }

  set nthline 0;
  while { [gets $FileId line] >= 0 } {
    incr nthline;
    set linelen [llength $line ];
    if { $linelen == 0  } { continue; }

    # Skip lines that begin with `#`
    set tmp [lindex $line 0];
    set firstchar [string index $tmp 0];
    if { $firstchar == "#" } { continue; }

    if { $linelen != 4 } {
       puts "ERROR: $seqcfgfile is formatted incorrectly"
       puts "  Line $nthline has [llength $line ] elements."
       puts "  Expecting 4 elements: SeqName, Dir, Format, Basename";
       puts " $line";
       puts $LF "ERROR: $seqcfgfile is formatted incorrectly"
       puts $LF "  Line $nthline has [llength $line ] elements."
       puts $LF "  Expecting 4 elements: SeqName, Dir, Format, Name";
       puts $LF " $line";
       exit 1;
    }
    #puts $line
    lappend seqcfg $line;
  }
  close $FileId;

  return $seqcfg;
}
#---------------------------------------------------------------#
proc GetSeqUnpackCfg { TargSeq SeqCfgList } {

  foreach SeqCfg $SeqCfgList {
    set Seq [lindex $SeqCfg 0];
    if { [string compare $TargSeq $Seq]  == 0 } {
       return $SeqCfg;
    }
  }
  puts "INFO: cannot find a match for $TargSeq in Sequence Config, skipping";
  return "skip";
  #exit 1;
}
#------------------------------------------------------------------#
proc ArgNError { option n } {
  if { $n == 1 } {
    puts "ERROR: flag $option needs 1 argument";
  } else {
    puts "ERROR: flag $option needs $n arguments";
  }
  exit 1;
}
#------------------------------------------------------------------#
proc ReadUnpackCfg { cfgfile } {
  global LF;

  if [catch {open $cfgfile r} FileId] {
     puts "Cannot open $cfgfile";
     puts $LF "Cannot open $cfgfile";
     exit 1;
  }

  set nthline 0;
  while { [gets $FileId line] >= 0 } {
    incr nthline;
    set linelen [llength $line ];
    if { $linelen == 0  } { continue; }
    if { $linelen != 4 } {
       puts "ERROR: $cfgfile is formatted incorrectly"
       puts "  Line $nthline has [llength $line ] elements."
       puts "  Expecting 4 elements: RunNo, Dir, Format, Name";
       puts " $line";
       puts $LF "ERROR: $cfgfile is formatted incorrectly"
       puts $LF "  Line $nthline has [llength $line ] elements."
       puts $LF "  Expecting 4 elements: RunNo, Dir, Format, Name";
       puts $LF " $line";
       exit 1;
    }
    lappend unpackcfg $line;
  }
  close $FileId;

  return $unpackcfg;
}
#------------------------------------------------------------------#
proc CheckUnpackCfgDuplication { unpackcfg } {
  # Looks for duplicate run numbers in the unpacking config
  global LF;

  set nruns [llength $unpackcfg];
  if { $nruns == 0 } {
    puts "ERROR: no runs found in the configuration."
    puts $LF "ERROR: no runs found in the configuration."
    exit 1;
  }

  set nthRun  0;
  foreach runcfg $unpackcfg {
    incr nthRun;
    set RunNo [lindex $runcfg 0];
    if { $RunNo < 1 } {
      puts "ERROR: nthRun=$nthRun has an invalid run number ($RunNo)"
      puts $LF "ERROR: nthRun=$nthRun has an invalid run number ($RunNo)"
      exit 1;
    }
    lappend runnolist $RunNo;
  }

  set runnolist [lsort $runnolist];

  set PrevRunNo 0;
  foreach RunNo $runnolist {
    if { $PrevRunNo == $RunNo } {
      puts "INFO: Run number $RunNo is duplicated "
      puts $LF "INFO: Run number $RunNo is duplicated "
      #exit 1;
    }
    set PrevRunNo $RunNo;
  }

  return 0;
}
#------------------------------------------------------------------#
proc CheckUnpackCfgFormat { unpackcfg } {
  # Checks that all the formats listed in the unpacking
  # congfiguration are valid.
  global LF;

  set nruns [llength $unpackcfg];
  if { $nruns == 0 } {
    puts "ERROR: no runs found in the configuration."
    puts $LF "ERROR: no runs found in the configuration."
    exit 1;
  }

  set nthRun  0;
  foreach runcfg $unpackcfg {
    incr nthRun;
    set RunNo [lindex $runcfg 0];
    set Fmt0  [lindex $runcfg 2];
    if { [string compare $Fmt0 skip] == 0} {continue;}
    set Fmt [string tolower $Fmt0];

    if { [string compare $Fmt bshort]  != 0 && \
         [string compare $Fmt bfloat]  != 0 && \
         [string compare $Fmt cor]     != 0 && \
         [string compare $Fmt spm]     != 0 && \
         [string compare $Fmt analyze] != 0 && \
         [string compare $Fmt minc]    != 0 && \
         [string compare $Fmt dicom]   != 0 && \
         [string compare $Fmt nii]     != 0 && \
         [string compare $Fmt mgz]     != 0 && \
         [string compare $Fmt mgh]     != 0 } {
      puts "ERROR: Run $RunNo has an invalid format ($Fmt0)"
      puts "       $runcfg"
      puts $LF "ERROR: Run $RunNo has an invalid format ($Fmt0)"
      puts $LF "       $runcfg"
      exit 1;
    }

    if { [string compare $Fmt minc] == 0 } {
      puts ""
      puts "WARNING: you have chosen MINC format. The orientation"
      puts "of the output may be incorrect."
      puts ""
    }

  }

  return 0;
}

#------------------------------------------------------------------#
proc CheckUnpackCfgExist { unpackcfg SeriesList} {
  # Checks that the runs listed in the unpacking configuration
  # actually exist in the session.
  global LF;

  set nruns [llength $unpackcfg];
  if { $nruns == 0 } {
    puts "ERROR: no runs found in the configuration."
    puts $LF "ERROR: no runs found in the configuration."
    exit 1;
  }

  set nseries [llength $SeriesList];
  if { $nruns == 0 } {
    puts "ERROR: no series found in series list."
    puts $LF "ERROR: no series found in series list."
    exit 1;
  }

  set nthRun  0;
  foreach runcfg $unpackcfg {
    incr nthRun;
    set RunNo [lindex $runcfg 0];
    GetRunSeries $RunNo $SeriesList; # exits on error
  }

  return 0;
}
#------------------------------------------------------------------#
proc GetRunSeries { RunNo SeriesList} {
  # This returns the line from the Series Leader List 
  # corresponding to the given run number.

  set ok 0;
  foreach series $SeriesList {
    set SeriesNo [lindex $series 2];
    if { $RunNo == $SeriesNo } { return $series }
  }

  puts "ERROR: Run $RunNo does not exist in session."
  exit 1;
}
#------------------------------------------------------------------#
proc GetSeriesIndex { RunNo SeriesList} {
  # This returns the zero-based index into the Series Leader List 
  # corresponding to the given run number.

  set nthRun 0;
  set ok 0;
  foreach series $SeriesList {
    set SeriesNo [lindex $series 2];
    if { $RunNo == $SeriesNo } { return $nthRun }
    incr nthRun;
  }

  puts "ERROR: Run $RunNo does not exist in session."
  exit 1;
}
#------------------------------------------------------------------#
proc GetVolRes { dcmfile  } {
  global LF;
  # Gets the distance between the columns, rows, and slices by
  # probing the DICOM file.

  # Pixel Spacing: string of the form ColRes\RowRes #
  set err [catch {exec mri_probedicom --i $dcmfile --t 28 30} PixSpace];
  if { $err } {
    puts stdout "ERROR: reading $dcmfile tag 28 30"
    puts $LF "ERROR: reading $dcmfile tag 28 30"
    exit 1;
  }
  set PixSpace [split $PixSpace \\];
  set ColRes   [lindex $PixSpace 0];
  set RowRes   [lindex $PixSpace 1];

  # Slice Spacing: get 18,88 first, then get 18,50 #
  set err [catch {exec mri_probedicom --i $dcmfile --t 18 88} SliceRes];
  if { $err } {
    set err [catch {exec mri_probedicom --i $dcmfile --t 18 50} SliceRes];
    if { $err } {
      puts stdout "ERROR: reading slice resolution from $dcmfile"
      puts $LF    "ERROR: reading slice resolution from $dcmfile"
      exit 1;
    }
  }

  set VolRes [list $ColRes $RowRes $SliceRes];

  return $VolRes;
}
#------------------------------------------------------------------#
proc ReadParsePipe { ParsePipe } {

  global ParsePipeContents;
  
  if { [eof $ParsePipe] } { 
    return 1 ;
  }

  if { [gets $ParsePipe line] > 0 } {
    lappend  ParsePipeContents $line;
  }

  return 0;
}

#------------------------------------------------------------------#
#--------------------- main ---------------------------------------#
#------------------------------------------------------------------#

#global dicomdir targdir sortmethod cfgfile unpackcfg noexec;

set sortmethod fsfast
set noexec 0
set scanonly 0
set nspmzeropad 3
set unpackerr 1
set DoInfoDump 1
set Sphinx 0
set SkipMoCo 0
set LogFile ""

if { $argc == 0 } { PrintUsage; exit 1;}

ParseCommandLine $argc $argv;
CheckArgs;

set mriconvert mri_convert

# Dump some info to the screen
puts "";
puts {$Id: unpacksdcmdir,v 1.19.2.2 2008/03/11 19:56:38 nicks Exp $};
puts "Sphinx: $Sphinx";
puts "";
puts [pwd];
puts "$argv"
puts "";
puts [exec date];
puts "";
puts [exec mri_convert -all-info];
puts "";
puts [exec hostname];
puts [exec uname -a];
puts "";

# Check that the input directory is there #
if {! [file exists $dicomdir]} {
  puts stdout "ERROR: directory $dicomdir does not exist"
  exit 1;
}

# Check that the target directory is writable
set targparent [file dirname $targdir];
if { ! [file writable $targparent] } {
   puts "ERROR: user does not have write permission to $targparent"
   exit 1;
}
# Create the target directory
set err [catch {file mkdir $targdir}];
if { $err } {
  puts "ERROR: could not make $targdir"
  exit 1;
}
if { ! [string compare $sortmethod fsfast ] } {
  set DoInfoDump 1
}

set StartTime [exec date];
puts $StartTime;

# Create a Log File #
if { [llength $LogFile] == 0 } {
  set LogFile "$targdir/unpack.log"
}
puts "Log File is $LogFile";
if [catch {open $LogFile w} LF] {
  puts "Cannot open $LogFile";
  exit 1;
}
puts "INFO: Logfile is $LogFile"
puts $LF "Log file created by unpacksdcmdir"
puts $LF {$Id: unpacksdcmdir,v 1.19.2.2 2008/03/11 19:56:38 nicks Exp $};
puts $LF "$LogFile"
puts $LF [pwd];
puts $LF [exec date];
puts $LF "$argv"
puts $LF [exec mri_convert -all-info];
puts $LF [exec hostname];
puts $LF [exec uname -a];
puts $LF "SkipMoCo $SkipMoCo";
puts "SkipMoCo $SkipMoCo";
flush $LF

puts $LF "dicomdir $dicomdir"

# Get a summary of the data in the source directory #
set sumfile  "$targdir/dicomdir.sumfile";
file delete -force $sumfile
set statfile "$targdir/parse.status";
file delete -force $statfile

puts $LF "Scanning source directory ..."
puts "Scanning source directory ..."

#----------------- Parse the source directory --------------------#
# Set up the parsing process as an open pipe without blocking #
puts $LF "INFO: summary file is $sumfile"
puts     "INFO: summary file is $sumfile"
puts $LF "INFO: status file is $statfile"
puts     "INFO: status file is $statfile"
puts "Scanning directory [exec date]"
puts     "mri_parse_sdcmdir --sortbyrun --d $dicomdir --o $sumfile --status $statfile"
puts $LF "mri_parse_sdcmdir --sortbyrun --d $dicomdir --o $sumfile --status $statfile"
flush $LF
set ParsePipeId [open \
"|mri_parse_sdcmdir --sortbyrun --d $dicomdir --o $sumfile --status $statfile 2>@ stdout" r];
fconfigure $ParsePipeId -blocking 0
flush $LF

# Wait until the statfile is created (or timeout after 20)
set ProbeStart [clock seconds];
set TimeSince 0
while { ! [file exists $statfile] && $TimeSince < 20 } {
  after 500;
  set TimeSince [expr [clock seconds] - $ProbeStart];
}
if { ! [file exists $statfile] } {
  puts $LF "ERROR: creation of statfile timed out"
  puts "ERROR: creation of statfile timed out"
  exit 1;
}
# Poll the parsing process until it is finished
set ParsePipeDone 0
set pct -1
while { ! $ParsePipeDone } {

   after 10; # Give status every 10 milisecond

   set ParsePipeDone [ReadParsePipe $ParsePipeId];

   set statfid [open $statfile r];
   set pctnew [read -nonewline $statfid];
   close $statfid
   # puts "$pct $pctnew"

   if { $pctnew == $pct } { continue }
   set pct $pctnew;
   puts -nonewline "$pct "
   flush stdout
}
puts ""
flush stdout
foreach line  $ParsePipeContents {
  puts $LF $line 
}
set err [ catch { close $ParsePipeId } ];
if { $err } {
  puts $LF "ERROR: parsing $dicomdir "
  puts "ERROR: parsing $dicomdir "
  exit 1;
}
file delete -force $statfile
puts $LF "Done scanning [exec date]"
puts "Done scanning [exec date]"
flush stdout
flush $LF
#------------------------------------------------------------------#

if { $scanonly } {
  # Open the scan file #
  if [catch {open $scanfile w} ScanFileId] {
    puts $LF "Cannot open $scanfile";
    puts "Cannot open $scanfile";
    exit 1;
  }
}

# Open the summary file #
if [catch {open $sumfile r} FileId] {
  puts $LF "Cannot open $sumfile";
  puts "Cannot open $sumfile";
  exit 1;
}

# Go through the summary file line-by-line
puts $LF "------------------------------------------"
puts "------------------------------------------"
set nthline 0;
set firstpass 1;
set PrevSeriesNo -1;
while { [gets $FileId line] >= 0 } {
  incr nthline;

  set linelen [llength $line ];
  if { $linelen == 0  } { continue; }
  if { $linelen != 13 } {
       puts $LF "ERROR: $sumfile is formatted incorrectly"
       puts $LF "  Line $nthline has $linelen elements, expecting 13."
       puts $LF "  $line";
       puts "ERROR: $sumfile is formatted incorrectly"
       puts "  Line $nthline has $linelen elements, expecting 13."
       puts "  $line";
       exit 1;
  }
  lappend sumfilelist $line;

  set DCMFile   [lindex $line  1];
  set SeriesNo  [lindex $line  2];
  set SeriesErr [lindex $line  3];
  set NRows     [lindex $line  6];
  set NCols     [lindex $line  7];
  set NSlices   [lindex $line  8];
  set NFrames   [lindex $line  9];
  set TR        [lindex $line 10];
  set Protocol  [lindex $line 12];
  if { $SeriesErr } { set ErrFlag err 
  } else { set ErrFlag ok }

  set Info [list $SeriesNo $Protocol $ErrFlag  $NCols \
                 $NRows $NSlices $NFrames $DCMFile];
  set InfoFmt "%3d %20s %3s  %3d %3d %3d %3d %s" 

  # Check for Series Leaders by looking for a change in
  # the Series Number
  if { $firstpass || $PrevSeriesNo != $SeriesNo } { 
    puts $LF [format $InfoFmt $SeriesNo $Protocol $ErrFlag  $NCols \
                 $NRows $NSlices $NFrames $DCMFile];
    puts [format $InfoFmt $SeriesNo $Protocol $ErrFlag  $NCols \
              $NRows $NSlices $NFrames $DCMFile];
    if { $scanonly } {
      puts $ScanFileId [format $InfoFmt $SeriesNo $Protocol $ErrFlag  \
              $NCols $NRows $NSlices $NFrames $DCMFile];
    }

    set PrevSeriesNo $SeriesNo;
    lappend SeriesLeaders $line;
    if { ! $firstpass } {
      lappend SeriesFileLists $FilesInRun;
      set FilesInRun {}
    }
    set firstpass 0;
  }

  # Keep a list of the files in each series
  lappend FilesInRun $DCMFile;
}

if { $nthline == 0 } {
  puts $LF "ERROR: no dicom files found in $dicomdir"
  puts "ERROR: no dicom files found in $dicomdir"
  # Check again that the input directory is there #
  if {! [file exists $dicomdir]} {
    puts $LF "There could be network trouble because $dicomdir existed "
    puts $LF "at the beginning of this process but can no long be found."
    puts "There could be network trouble because $dicomdir existed "
    puts "at the beginning of this process but can no long be found."
    exit 1;
  }
  exit 1;
}

lappend SeriesFileLists $FilesInRun;
close $FileId;

if { $scanonly } { 
  close $ScanFileId;
  exit 0; 
}

# Create upackcfg from Sequence Configuration #
if { [info exists seqcfgfile] } {
  set SeqCfgList [ReadSeqCfg $seqcfgfile];
}
if { [info exists SeqCfgList] } {
  puts $LF "------------------------------------------"
  puts $LF "Automatically configuring unpack ..."
  puts "------------------------------------------"
  puts "Automatically configuring unpack ..."
  flush stdout
  flush $LF
  foreach Series $SeriesLeaders {
    set ErrFlag  [lindex $Series  3];
    if { $ErrFlag && ! $unpackerr} { continue; }

    set RunNo    [lindex $Series  2];
    set Protocol [lindex $Series 12];

    set SeqUnpackCfg [GetSeqUnpackCfg $Protocol $SeqCfgList];
    puts "SeqUnpackCfg $SeqUnpackCfg"
    if { [string compare $SeqUnpackCfg skip] != 0 } {
      set dirid      [lindex $SeqUnpackCfg 1];
      set unpackfmt  [lindex $SeqUnpackCfg 2];
      set basename   [lindex $SeqUnpackCfg 3];
      set unpackname $basename
      if { [string compare $sortmethod "generic"] == 0} {
        switch -exact -- [string tolower $unpackfmt] {
          spm     {set unpackname [format "%s%03d" $basename $RunNo]}
          analyze {set unpackname [format "%s%03d" $basename $RunNo]}
          minc    {set unpackname [format "%s%03d" $basename $RunNo]}
          mgh     {set unpackname [format "%s%03d" $basename $RunNo]}
          bshort  {set unpackname [format "%s%03d" $basename $RunNo]}
          bfloat  {set unpackname [format "%s%03d" $basename $RunNo]}
          cor     {set unpackname [format "%03d"   $RunNo]}
        }
      }
      puts "$RunNo $Protocol $dirid $unpackfmt $unpackname"
    } else {
      set dirid       skip;
      set unpackfmt   skip;
      set basename    skip;
      set unpackfmt   skip;
      set unpackname  skip;
    }
    set cfg [list $RunNo $dirid $unpackfmt $unpackname];
    lappend unpackcfg $cfg;
  }
}

CheckUnpackCfgDuplication $unpackcfg;
CheckUnpackCfgFormat      $unpackcfg;
puts $LF "sortmethod $sortmethod"
puts $LF "unpacking config ------------------"
puts $LF $unpackcfg;
puts $LF "-----------------------------------"

puts "unpacking config ------------------"
puts $unpackcfg;
puts "-----------------------------------"

flush stdout
flush $LF

# Check that each run listed in the configuration
# actually exists in the session.
CheckUnpackCfgExist  $unpackcfg $SeriesLeaders;

# Now unpack each run #
foreach runcfg $unpackcfg {
  set RunNo  [lindex $runcfg 0];
  set SubDir [lindex $runcfg 1];
  set Fmt    [lindex $runcfg 2];
  set Name   [lindex $runcfg 3];
  if { [string compare $Fmt skip ] == 0} {continue;}
  set nthRun [GetSeriesIndex $RunNo $SeriesLeaders];

  puts $LF "---------------------------------------------------------"
  puts $LF "Run $RunNo -----------------------------------------"
  puts $LF [exec date];
  puts $LF $runcfg
  puts "---------------------------------------------------------"
  puts "Run $RunNo -----------------------------------------"
  puts [exec date];
  puts $runcfg
  flush stdout
  flush $LF

  if { ! [string compare $sortmethod fsfast ] } {
    set OutDir [format "%s/%s/%03d" $targdir $SubDir $RunNo];
  } else {
    set OutDir [format "%s/%s" $targdir $SubDir];
  }

  set OutType {}
  set Fmt [string tolower $Fmt];
  if { ! [string compare $Fmt bshort ] } {
     set OutFile [format "%s/%s_000.bshort" $OutDir $Name];
  } elseif { ! [string compare $Fmt bfloat] } {
     set OutFile [format "%s/%s_000.bfloat" $OutDir $Name];
  } elseif { ! [string compare $Fmt spm ] } {
     set OutFile [format "%s/%s" $OutDir $Name];
  } elseif { ! [string compare $Fmt analyze ] } {
     set OutFile [format "%s/%s.img" $OutDir $Name];
     set Fmt analyze4d
  } elseif { ! [string compare $Fmt minc ] } {
     set OutFile [format "%s/%s" $OutDir $Name];
  } elseif { ! [string compare $Fmt nii ] } {
     set OutFile [format "%s/%s" $OutDir $Name];
  } elseif { ! [string compare $Fmt mgz ] } {
     set OutFile [format "%s/%s" $OutDir $Name];
  } elseif { ! [string compare $Fmt mgh ] } {
     set OutFile [format "%s/%s" $OutDir $Name];
  } else {
     set OutFile $OutDir;
  }

  set Series   [GetRunSeries $RunNo $SeriesLeaders];

  set ErrFlag  [lindex $Series  3];
  if { $ErrFlag  && ! $unpackerr } { 
    puts $LF "INFO: this run has an error, skipping";
    puts "INFO: this run has an error, skipping";
    continue; 
  }

  if { $ErrFlag } { 
    puts $LF "INFO: this run has an error, but trying anyway";
    puts "INFO: this run has an error, but trying anyway";
  }

  set DCMFile  [lindex $Series  1];
  set DCMSource [format "%s/%s" $dicomdir $DCMFile];
  if { ! [file exists $DCMSource ] } {
    puts "ERROR: cannot find $DCMSource"
    exit 1;
  }

  if { $SkipMoCo } {
    set err [catch {exec mri_probedicom --i $DCMSource --t 8 103e} SeriesDescription];
    puts $LF "Series Description $SeriesDescription";
    puts "Series Description $SeriesDescription";
    if { ! $err } {
        if { ! [string compare $SeriesDescription MoCoSeries ] } {
	    puts $LF "INFO: this run is MoCo, skipping";
	    puts "INFO: this run is MoCo, skipping";
	    continue; 
        }
    }
  }
  set NRows    [lindex $Series  6];
  set NCols    [lindex $Series  7];
  set NSlices  [lindex $Series  8];
  set NFrames  [lindex $Series  9];
  set TR       [lindex $Series 10];
  set Protocol [lindex $Series 12];
  set FilesInRun [lindex $SeriesFileLists $nthRun];

  puts $LF "Files In Run: ---------------"
  puts $LF $FilesInRun;
  puts $LF "-----------------------------"
  flush stdout
  flush $LF

  set VolRes [GetVolRes $DCMSource];

  set ColRes   [lindex $VolRes 0];
  set RowRes   [lindex $VolRes 1];
  set SliceRes [lindex $VolRes 2];
  puts $LF "VolRes: $ColRes $RowRes $SliceRes";

  # OK, now make output directory
  set err [catch {file mkdir $OutDir}];
  if { $err } {
    puts "ERROR: could not make $OutDir"
    exit 1;
  }

  # Create the seq.info file if using FS-FAST sorting #
  if { ! [string compare $sortmethod fsfast ] } {
    set SeqInfo [format "%s/%s/seq.info" $targdir $SubDir];
    if [catch {open $SeqInfo w} SeqInfoId] {
      puts "Cannot open $SeqInfo";
      exit 1;
    }
    puts $SeqInfoId "sequencename $Protocol";
    puts $SeqInfoId "nrows $NRows";
    puts $SeqInfoId "ncols $NCols";
    puts $SeqInfoId "nslcs $NSlices";
    puts $SeqInfoId "rowpixelsize $RowRes";
    puts $SeqInfoId "colpixelsize $ColRes";
    puts $SeqInfoId "slcpixelsize $SliceRes";
    if { $NFrames > 1 } {
      puts $SeqInfoId "ntrs $NFrames";
      puts $SeqInfoId "TR   $TR";
    }
  }

  if { $DoInfoDump } {
    # Create an info dumpfile #
    set DumpFile "$OutDir/$Name-infodump.dat"
    set err [catch {exec -keepnewline mri_probedicom --i $DCMSource >& \
                     $DumpFile} dumplog];
    if { $err } {
       puts "ERROR: creating info dump file";
       puts $dumplog;
       exit 1;
    }
  }

  # Now run mri_convert or copy dicom files #
  if { [string compare $Fmt dicom ] } {
    # Use mri_convert #

    # create a file list file for faster conversion #
    set flf "$OutDir/flf";
    set flfid [open $flf w];
    puts $flfid "$FilesInRun"
    close $flfid

    puts $LF "------- mri_convert ------------- SO"
    if { $Sphinx} {
    set cnvcmd [list $mriconvert $DCMSource $OutFile --sdcmlist $flf \
               -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom --sphinx];
    }	else {
    set cnvcmd [list $mriconvert $DCMSource $OutFile --sdcmlist $flf \
               -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom];

    }

    puts $LF $cnvcmd
    puts $LF "-----------------------"

    if { ! $noexec } {
    
    if {$Sphinx} {
      puts "$mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom --sphinx"
      puts $LF "$mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom --sphinx"
      } else {
      puts "$mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom"
      puts $LF "$mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt --nspmzeropad $nspmzeropad --in_type siemens_dicom"
      
      }
      
   if {$Sphinx} {
 
      set err [catch {exec -keepnewline \
          $mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt \
                      --nspmzeropad $nspmzeropad --in_type siemens_dicom --sphinx\
                       >&@ $LF } mriconvlog];
    } else {

     set err [catch {exec -keepnewline \
          $mriconvert $DCMSource $OutFile --sdcmlist $flf -ot $Fmt \
                      --nspmzeropad $nspmzeropad --in_type siemens_dicom\
                       >&@ $LF } mriconvlog];
 
}
      puts $LF $mriconvlog;
      if { $err } {
         puts $LF "ERROR: mri_convert";
         puts "ERROR: mri_convert";
         puts $mriconvlog;
         exit 1;
      }
    }
    # delete the file list file #
    # file delete $flf;

  } else {
    #-------- copy dicom files ------#
    puts $LF "Copying DICOM files"
    foreach dcmfile $FilesInRun {
      set srcdcmpath "$dicomdir/$dcmfile"
      set trgdcmpath "$OutDir/$dcmfile"
      if { ! $noexec } {
        file copy -force $srcdcmpath $trgdcmpath;
      }
    }
  }
  flush stdout
  flush $LF

}; # end loop over the unpacking of each run #


puts $LF "StartTime: $StartTime"
puts $LF "EndTime:   [exec date]"
puts $LF "unpacksdcmdir Done"

close $LF;

puts " "
puts " "
puts "StartTime: $StartTime"
puts "EndTime:   [exec date]"
puts "unpacksdcmdir Done"

puts " "


exit 0;
#---------------- End Main ---------------------------#



