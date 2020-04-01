% Copyright 2017 Harrison Pratt
/*
    These predicates are from Kari Rastas code with minor modification.  Thanks, Kari!
    See: http://discuss.visual-prolog.com/viewtopic.php?t=15519&sid=ea9f13294db27a2156a167741afc202b
*/

class screenCapture

    open core

predicates

    %-- window image capture and saving

    getClientBmp : (window W) -> bitmap.

    clientWin_saveAsFile : (window, string FileName, string FileTypeEncoder).

    clientWin_putClipboardBMP : (window).

predicates
    savePictureToFile : (vpiDomains::picture, string FileName, string EncoderType) language stdcall as "savePictureToFile".
    %
    %@short Saves a picture in a file with the wanted picture format
    %
    %@detail Saves a picture in a file with the wanted picture format
    %
    %Possible formats are bmp, gif, jpeg, tiff and png
    %
    %@example
    %  PICTURE = O: getPicture(),
    %  savePictureToFile(PICTURE,"example1.jpg","jpeg"),
    %  savePictureToFile(PICTURE,"example2.bmp","bmp"),
    %  savePictureToFile(PICTURE,"example3.tif","tiff"),
    %  savePictureToFile(PICTURE,"example4.png","png"),
    %
    %@end
    %

    savePictureToFileJPEG : (vpiDomains::picture, string FileName) language stdcall as "savePictureToFileJPEG".
    %
    %@short Saves a picture in a file with jpeg format
    %
    %@detail Saves a picture in a file with jpeg format
    %
    %@example
    %  PICTURE = O: getPicture(),
    %  savePictureToFileJPEG(PICTURE,"example12.jpg"),
    %
    %@end
    %

    pictureFileToStringForHtml : (string PictureFileName, string PctureType, string NameText, unsigned Width, unsigned Height) -> string PicStr
        language stdcall as "pictureFileToStringForHtml".
    %
    %@short Produces from a picture file a string to be embedded in a html page
    %
    %@detail Produces from a picture file a string to be embedded in a html page.
    %
    %<img src=\"data:image/%;base64,%s\" alt=\"%s\" width=\"%\" height=\"%\">
    %
    %@example
    %  PICTURE = O: getPicture(),
    %  pictureFileToStringForHtml("example12.jpg","Export to USA in 2015",500, 250) = PictureStr,
    %
    %@end
    %

    pictureToStringForHtml : (vpiDomains::picture [in], string NameText [in], unsigned Width [in], unsigned Height [in]) -> string PicStr
        language stdcall as "pictureToStringForHtml".
    %
    %@short Produces from a picture a string to be embedded in a html page
    %
    %@detail Produces from a picture a string to be embedded in a html page.
    %
    %<img src=\"data:image/%;base64,%s\" alt=\"%s\" width=\"%\" height=\"%\">
    %
    %@example
    %  PICTURE = O: getPicture(),
    %  pictureToStringForHtml(PICTURE,"Export to USA in 2015",500, 250) = PictureStr,
    %
    %@end
    %

end class screenCapture
