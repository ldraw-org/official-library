LDraw Readme File

Welcome to LDraw!
This short readme file explains what files and subdirectories are
present in your LDraw installation, and has links to some sites on
the internet where you can find help and further information.

 * LDraw program directory contents
 * More information/help available online
 * Parts Updates

----------------------------------------------------------------------
* What is contained in the LDraw directory:
 - Program executables:
   LDraw.exe    -  This is the command line run program used to
                   render *.DAT files.
                   This program must be run with command line arguments to
                   work, such as:
                      ldraw.exe car.dat
                   More details on the command line arguments for LDraw.exe can
                   be found in LDraw.txt.  Or you can use a "shell" program to
                   run it, such as LDraw Add-On or LDraw Launcher.  (This is
                   highly recommended - much easier than typing in command line
                   arguments)
   LEdit.exe    -  This is the interactive modelling program used to create models.
                   This program is a simple graphic modelling program using
                   keyboard inputs to place pieces in your model.  More details
                   on using LEdit can be found in the LEdit.txt file, and in the
                   tutorials available for it.
                   This program seems difficult at first glance, but is really much 
                   easier to use than it first appears. And a lot of help is available
                   from experienced users on the LUGNET newsgroups.
   MKList.exe   -  This is a utility that creates a list of available
                   parts. This list (parts.lst) is used by LEdit and
                   by several other third-party utilities. You should
                   re-run MKList after installing new parts updates, 
                   or you may run it at any other time to change the
                   sort order of your list of parts.
   Rtm.exe      -  A subroutine program used by LDraw.exe and LEdit.exe
   SL2LD.exe    -  Conversion program. Used to convert SimLego files
                   to LDraw files. (The SL2LD program is no longer supported)

 - Support Files:
   Parts.lst    -  This is your listing of all usable parts available.
                   This list is created by running MKList.exe and choosing
                   to create the list sorted Numerically or by Description.
                   Most people use Description sorting, but you can
                   change to whichever way you prefer at any time.
   SL2LD.lst    -  The parts list file used by the SL2LD conversion program.
                   (The SL2LD listing is no longer updated or supported)
   Cga.bgi      -  Graphics interface file used by LDraw and LEdit.
   Egavga.bgi   -  Graphics interface file used by LDraw and LEdit.
   Vesa16.bgi   -  Graphics interface file used by LDraw and LEdit.
   Dpmi16bi.ovl -  Program overlay file used by LDraw and LEdit.
   Update.scr   -  Screen driver file used by LDraw and LEdit.
   LDraw.pif    -  Basic Win9x Program Information File.
   LEdit.pif    -  Basic Win9x Program Information File.
   MKList-c.zip -  Zip archive of the MKList source code.

 - Informational Files:
   LDraw.htm    -  Short reference to command line usage of LDraw.exe in HTML format.
   LDraw.txt    -  Short reference to command line usage of LDraw.exe in text format.
   LEdit.htm    -  Short reference to usage of LEdit.exe in HTML format.
   LEdit.txt    -  Short reference to usage of LEdit.exe in text format.
   License.txt  -  Users license file detailing terms and conditions of use.
   Readme.htm   -  Readme file in HTML format. 
   Readme.txt   -  This file you are currently reading.
 
 - Subdirectories:
   \BITMAP\     -  This directory is where LDraw.exe saves .bmp-type
                   graphics screenshots of model files. This can be done by
                   using a combination of the -MS switch on the LDraw.exe
                   command line AND having '0 STEP' lines located in the .dat
                   file to be rendered.
                   Note: the file delete.me in this directory can be safely deleted.
   \MODELS\     -  This directory is where your model .dat files are stored.
                   There are two sample model .dat files installed for you
                   to look at - Car.dat and Pyramid.dat.
   \P\          -  This directory is where parts primitives are located.
                   Do not delete or alter these files.
   \PARTS\      -  This directory holds all the actual parts that can be used
                   in creating or rendering your models.  A list of these
                   parts can be seen by viewing the parts.lst file.
   \HTMIMAGE\   -  This directory contains image files for the HTML help pages.

----------------------------------------------------------------------
* For more information on LDraw, check out these internet resources:

 - LDraw.org  -  http://www.ldraw.org/
   Centralized LDraw Resources on the internet.
   Parts updates, Utility programs for using and enhancing LDraw, and more.

 - LUGNET  -  http://www.lugnet.com/
   The Lego Users Group NETwork (LUGNET) - A great place for fans of Lego.
   LUGNET has many topic-specific newsgroups that discuss LDraw and other forms
   of Lego-type CAD.
    
 - Instructions/Tutorials:
   -  LDraw/LEdit Tutorial  -  http://library.thinkquest.org/20551/home.html
      Bram Lambrecht's great online step-by-step Guide to learning how
      to use LDraw and LEdit. Can also be downloaded in a .zip file for
      offline study.  
   -  The LEdit Primer  -  A short primer on using LEdit in two formats.
      Plain text format: http://www.ldraw.org/memorial/archive/howto.txt
      MS Word 7.0 format: http://www.ldraw.org/memorial/archive/howto-word.doc

 - The LDraw Frequently Asked Questions (FAQ):
      http://www.ldraw.org/faq/

----------------------------------------------------------------------
* Parts Updates:

 - The basic archive of ldraw027.exe contains the original parts
   and programs for LDraw that were released by James Jessiman.
   Since the untimely passing of James, many parts have been created
   and officially added.

 - If you have not already done so, you should visit www.ldraw.org and
   download and install the full update package of new parts contained
   in the complete.exe file.

 - Periodically, new parts and part fixes are released in small updates,
   available from www.ldraw.org.  These updates should be downloaded and
   installed as they become available. Please remember that OLD updates
   should not be installed over NEW or NEWER updates.  Doing so might
   overwrite a fixed version of a part with an older version.

 - If you ever feel that you are missing parts, or something in your LDraw
   installation has been corrupted for any reason, the best recourse is to
   re-install the original archive - ldraw027.exe - followed by a new
   download of the complete exe file from www.ldraw.org.
   This will ensure that you have all the parts, with the latest fixes.


--end of file--   