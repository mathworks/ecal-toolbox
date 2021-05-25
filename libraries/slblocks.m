function blkStruct = slblocks
% This function specifies that the library 'eCAL_blks_lib'
% should appear in the Library Browser with the 
% name 'eCAL Blockset'

    Browser.Library = 'eCAL_blks_lib';

    Browser.Name = 'eCAL Blockset';
    % 'eCAL Blockset' is the library name that appears
    % in the Library Browser

    blkStruct.Browser = Browser;