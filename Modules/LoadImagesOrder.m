function handles = AlgLoadImagesOrder(handles)

%%% Reads the current algorithm number, since this is needed to find 
%%% the variable values that the user entered.
CurrentAlgorithm = handles.currentalgorithm;

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%

%textVAR1 = The images to be loaded are located in what position in each set? (1,2,3,...)
%defaultVAR1 = 1
fieldname = ['Vvariable',CurrentAlgorithm,'_01'];
NumberInSet1 = handles.(fieldname);
%textVAR2 = What do you want to call these images?
%defaultVAR2 = OrigBlue
fieldname = ['Vvariable',CurrentAlgorithm,'_02'];
ImageName1 = handles.(fieldname);
%textVAR3 = The images to be loaded are located in what position in each set? (1,2,3,...)
%defaultVAR3 = 0
fieldname = ['Vvariable',CurrentAlgorithm,'_03'];
NumberInSet2 = handles.(fieldname);
%textVAR4 = What do you want to call these images?
%defaultVAR4 = OrigGreen
fieldname = ['Vvariable',CurrentAlgorithm,'_04'];
ImageName2 = handles.(fieldname);
%textVAR5 = The images to be loaded are located in what position in each set? (1,2,3,...)
%defaultVAR5 = 0
fieldname = ['Vvariable',CurrentAlgorithm,'_05'];
NumberInSet3 = handles.(fieldname);
%textVAR6 = What do you want to call these images?
%defaultVAR6 = OrigRed
fieldname = ['Vvariable',CurrentAlgorithm,'_06'];
ImageName3 = handles.(fieldname);
%textVAR7 = The images to be loaded are located in what position in each set? (1,2,3,...)
%defaultVAR7 = 0
fieldname = ['Vvariable',CurrentAlgorithm,'_07'];
NumberInSet4 = handles.(fieldname);
%textVAR8 = What do you want to call these images?
%defaultVAR8 = OrigOther1
fieldname = ['Vvariable',CurrentAlgorithm,'_08'];
ImageName4 = handles.(fieldname);
%textVAR9 = How many images are there in each set (i.e. each field of view)?
%defaultVAR9 = 3
fieldname = ['Vvariable',CurrentAlgorithm,'_09'];
ImagesPerSet = handles.(fieldname);
%textVAR10 = Type the file format of the images
%defaultVAR10 = tif
fieldname = ['Vvariable',CurrentAlgorithm,'_10'];
FileFormat = handles.(fieldname);
%textVAR11 = Carefully type the directory path name where the images to be loaded are located
%defaultVAR11 = Default Directory - leave this text to retrieve images from the directory specified in STEP1
fieldname = ['Vvariable',CurrentAlgorithm,'_11'];
PathName = handles.(fieldname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Determines which set is being analyzed.
SetBeingAnalyzed = handles.setbeinganalyzed;
ImagesPerSet = str2num(ImagesPerSet);
SpecifiedPathName = PathName;
%%% If the user left boxes blank, the values are set to 0.
if isempty(NumberInSet1) == 1
    NumberInSet1 = '0';
end
if isempty(NumberInSet2) == 1
    NumberInSet2 = '0';
end
if isempty(NumberInSet3) == 1
    NumberInSet3 = '0';
end
if isempty(NumberInSet4) == 1
    NumberInSet4 = '0';
end
%%% Stores the text the user entered into cell arrays.
NumberInSet{1} = str2num(NumberInSet1);
NumberInSet{2} = str2num(NumberInSet2);
NumberInSet{3} = str2num(NumberInSet3);
NumberInSet{4} = str2num(NumberInSet4);
%%% Check whether the position in set exceeds the number per set.
Max12 = max(NumberInSet{1}, NumberInSet{2});
Max34 = max(NumberInSet{3}, NumberInSet{4});
Max1234 = max(Max12, Max34);
if ImagesPerSet < Max1234
    error(['Image processing was canceled because the position of one of the image types within each image set exceeds the number of images per set that you entered (', num2str(ImagesPerSet), ').'])
end
ImageName{1} = ImageName1;
ImageName{2} = ImageName2;
ImageName{3} = ImageName3;
ImageName{4} = ImageName4;
%%% Determines the current directory so the module can switch back at the
%%% end.
CurrentDirectory = cd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIRST IMAGE SET FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Extracting the list of files to be analyzed occurs only the first time
%%% through this module.
if SetBeingAnalyzed == 1
    %%% Checks whether the file format the user entered is readable by Matlab.
    IsFormat = imformats(FileFormat);
    if isempty(IsFormat) == 1
    error('The image file type entered in the Load Images Order module is not recognized by Matlab. Or, you may have entered a period in the box. For a list of recognizable image file formats, type "imformats" (no quotes) at the command line in Matlab.','Error')
    end
    %%% For all 4 image slots, the file names are extracted.
    for n = 1:4
        %%% Checks whether the two variables required have been entered by
        %%% the user.
        if NumberInSet{n} ~= 0 & isempty(ImageName{n}) == 0
            if strncmp(SpecifiedPathName, 'Default', 7) == 1
                PathName = handles.Vpathname;
                FileNames = handles.Vfilenames;
                if SetBeingAnalyzed == 1
                    if length(handles.Vfilenames) < ImagesPerSet
                        error(['In the Load Images Order module, you specified that there are ', num2str(ImagesPerSet),' images per set, but only ', num2str(length(handles.Vfilenames)), ' were found in the chosen directory. Please check the settings.'])    
                    end
                    %%% Determines the number of image sets to be analyzed.
                    NumberOfImageSets = fix(length(handles.Vfilenames)/ImagesPerSet);
                    %%% Checks whether another load images module has
                    %%% already recorded a number of image sets.  If it
                    %%% has, it will not be set at the default of 1.  Then,
                    %%% it checks whether the number already stored as the
                    %%% number of image sets is equal to the number of
                    %%% image sets that this module has found.  If not, an
                    %%% error message is generated. Note: this will not
                    %%% catch the case where the number of image sets
                    %%% detected by this module is more than 1 and another
                    %%% module has detected only one image set, since there
                    %%% is no way to tell whether the 1 stored in
                    %%% handles.Vnumberimagesets is the default value or a
                    %%% value determined by another image-loading module.
                    if handles.Vnumberimagesets ~= 1;
                        if handles.Vnumberimagesets ~= NumberOfImageSets
                        error(['The number of image sets loaded by the Load Images Order module (', num2str(NumberOfImageSets),') does not equal the number of image sets loaded by another image-loading module (', num2str(handles.Vnumberimagesets), '). Please check the settings.'])    
                        end
                    end
                    %%% The number of image sets is stored in the
                    %%% handles structure.
                    handles.Vnumberimagesets = NumberOfImageSets;
                else NumberOfImageSets = handles.Vnumberimagesets;
                end
                %%% Loops through the names in the FileNames listing,
                %%% creating a new list of files.
                for i = 1:NumberOfImageSets
                    Number = (i - 1) .* ImagesPerSet + NumberInSet{n};
                    FileList(i) = FileNames(Number);
                end
                %%% Saves the File Lists and Path Names to the handles structure.
                fieldname = ['dOTFileList', ImageName{n}];
                handles.(fieldname) = FileList;
                fieldname = ['dOTPathName', ImageName{n}];
                handles.(fieldname) = PathName;
                clear FileList
            else
                %%% If a directory was typed in, the filenames are retrieved
                %%% from the chosen directory.
                if exist(SpecifiedPathName) ~= 7
                    error('Image processing was canceled because the directory typed into the Load Images Order module does not exist. Be sure that no spaces or unusual characters exist in your typed entry and that the pathname of the directory begins with /.')
                else [handles, FileNames] = RetrieveImageFileNames(handles, SpecifiedPathName);
                    if SetBeingAnalyzed == 1
                        %%% Determines the number of image sets to be analyzed.
                        NumberOfImageSets = fix(length(FileNames)/ImagesPerSet);
                        handles.Vnumberimagesets = NumberOfImageSets;
                    else NumberOfImageSets = handles.Vnumberimagesets;
                    end
                    %%% Loops through the names in the FileNames listing,
                    %%% creating a new list of files.
                    for i = 1:NumberOfImageSets
                        Number = (i - 1) .* ImagesPerSet + NumberInSet{n};
                        FileList(i) = FileNames(Number);
                    end
                    %%% Saves the File Lists and Path Names to the handles structure.
                    fieldname = ['dOTFileList', ImageName{n}];
                    handles.(fieldname) = FileList;
                    fieldname = ['dOTPathName', ImageName{n}];
                    handles.(fieldname) = PathName;
                    clear FileList
                end
            end
        end
    end  % Goes with: for n = 1:4
    %%% Update the handles structure.
    %%% Removed for parallel: guidata(gcbo, handles);    
end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LOADING IMAGES EACH TIME %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:4
    %%% This try/catch will catch any problems in the load images module.
    try 
        if NumberInSet{n} ~= 0 & isempty(ImageName{n}) == 0
            %%% Determine which image to analyze.
            fieldname = ['dOTFileList', ImageName{n}];
            FileList = handles.(fieldname);
            %%% Determine the file name of the image you want to analyze.
            CurrentFileName = FileList(SetBeingAnalyzed);
            %%% Determine the directory to switch to.
            if (isfield(handles, 'parallel_machines')),
              fieldname = ['dOTPathName', ImageName{n}];
              PathName = handles.(fieldname);
            else
              PathName = handles.RemoteImagePathName;
            end
            %%% Switch to the directory
            cd(PathName);
            try
                %%% Read (open) the image you want to analyze and assign it to a variable,
                %%% "LoadedImage".
                LoadedImage = im2double(imread(char(CurrentFileName),FileFormat));
            catch error(['Image processing was canceled because the Load Images Order module could not load the image "', char(CurrentFileName), '" which you specified is in "', FileFormat, '" file format.'])
            end
            %%% Saves the original image file name to the handles structure.  The field
            %%% is named 
            %%% appropriately based on the user's input, with the 'dOT' prefix added so
            %%% that this field will be deleted at the end of the analysis batch.
            fieldname = ['dOTFilename', ImageName{n}];
            handles.(fieldname)(SetBeingAnalyzed) = CurrentFileName;
            %%% Saves the loaded image to the handles structure.The field is named
            %%% appropriately based on the user's input.The prefix 'dOT' is added to
            %%% the beginning of the measurement name so that this field will be
            %%% deleted at the end of the analysis batch.  
            fieldname = ['dOT',ImageName{n}];
            handles.(fieldname) = LoadedImage;
        end    
    catch ErrorMessage = lasterr;
        ErrorNumber(1) = {'first'};
        ErrorNumber(2) = {'second'};
        ErrorNumber(3) = {'third'};
        ErrorNumber(4) = {'fourth'};
        error(['An error occurred when trying to load the ', ErrorNumber{n}, ' set of images using the Load Images Order module. Please check the settings. A common problem is that there are non-image files in the directory you are trying to analyze. Matlab says the problem is: ', ErrorMessage])
    end % Goes with: catch
end
%%% Changes back to the original directory.
cd(CurrentDirectory)
%%% Update the handles structure.
%%% Removed for parallel: guidata(gcbo, handles);

%%%%%%%%%%%%%%%%%%%%
%%% FIGURE WINDOW %%%
%%%%%%%%%%%%%%%%%%%%

if SetBeingAnalyzed == 1
%%% The figure window display is unnecessary for this module, so the figure
%%% window is closed the first time through the module.
%%% Determines the figure number.
fieldname = ['figurealgorithm',CurrentAlgorithm];
ThisAlgFigureNumber = handles.(fieldname);
%%% If the window is open, it is closed.
if any(findobj == ThisAlgFigureNumber) == 1;
    close(ThisAlgFigureNumber)
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTION TO RETRIEVE FILE NAMES %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles, FileNames] = RetrieveImageFileNames(handles, PathName)
%%% Lists all the contents of that path into a structure which includes the
%%% name of each object as well as whether the object is a file or
%%% directory.
FilesAndDirsStructure = dir(PathName);
%%% Puts the names of each object into a list.
FileAndDirNames = sortrows({FilesAndDirsStructure.name}');
%%% Puts the logical value of whether each object is a directory into a list.
LogicalIsDirectory = [FilesAndDirsStructure.isdir];
%%% Eliminates directories from the list of file names.
FileNamesNoDir = FileAndDirNames(~LogicalIsDirectory);

if isempty(FileNamesNoDir) == 1
    errordlg('There are no files in the chosen directory')
    handles.Vfilenames = [];
else
%%% Makes a logical array that marks with a "1" all file names that start
%%% with a period (hidden files):
DiscardLogical1 = strncmp(FileNamesNoDir,'.',1);
%%% Makes logical arrays that mark with a "1" all file names that have
%%% particular suffixes (mat, m, m~, and frk). The dollar sign indicates
%%% that the pattern must be at the end of the string in order to count as
%%% matching.  The first line of each set finds the suffix and marks its
%%% location in a cell array with the index of where that suffix begins;
%%% the third line converts this cell array of numbers into a logical
%%% array of 1's and 0's.   cellfun only works on arrays of class 'cell',
%%% so there is a check to make sure the class is appropriate.  When there
%%% are very few files in the directory (I think just one), the class is
%%% not cell for some reason.
DiscardLogical2Pre = regexpi(FileNamesNoDir, '.mat$','once');
if strcmp(class(DiscardLogical2Pre), 'cell') == 1
DiscardLogical2 = cellfun('prodofsize',DiscardLogical2Pre);
else DiscardLogical2 = [];
end
DiscardLogical3Pre = regexpi(FileNamesNoDir, '.m$','once');
if strcmp(class(DiscardLogical3Pre), 'cell') == 1
DiscardLogical3 = cellfun('prodofsize',DiscardLogical3Pre);
else DiscardLogical3 = [];
end
DiscardLogical4Pre = regexpi(FileNamesNoDir, '.m~$','once');
if strcmp(class(DiscardLogical4Pre), 'cell') == 1
DiscardLogical4 = cellfun('prodofsize',DiscardLogical4Pre);
else DiscardLogical4 = [];
end
DiscardLogical5Pre = regexpi(FileNamesNoDir, '.frk$','once');
if strcmp(class(DiscardLogical5Pre), 'cell') == 1
DiscardLogical5 = cellfun('prodofsize',DiscardLogical5Pre);
else DiscardLogical5 = [];
end

%%% Combines all of the DiscardLogical arrays into one.
DiscardLogical = DiscardLogical1 | DiscardLogical2 | DiscardLogical3 | DiscardLogical4 | DiscardLogical5;
%%% Eliminates filenames to be discarded.
if isempty(DiscardLogical) == 1
    FileNames = FileNamesNoDir;
else FileNames = FileNamesNoDir(~DiscardLogical);
end
%%% Checks whether any files are left.
if isempty(FileNames) == 1
    errordlg('There are no image files in the chosen directory')
end
end

%%%%%%%%%%%
%%% HELP %%%
%%%%%%%%%%%

%%%%% Help for Load Images Order module:
%%%%% .
%%%%% This module is required to Load Images Order from the hard drive into a
%%%%% format recognizable by CellProfiler.  The images are given a
%%%%% meaningful name, which is then used by subsequent modules to retrieve
%%%%% the proper image.  If more than five images per set must be loaded,
%%%%% more than one Load Images Order module can be run sequentially. 