% Copyright 2018 Harrison Pratt

class gdipTools

    open core

constants % hwp

    gdip_encoderList : string_list = ["BMP", "JPEG", "PNG", "TIFF"].
    gdip_decoderList : string_list = ["BMP", "JPEG", "PNG", "TIFF", "WMF", "EMF", "ICON"].

% SEE: https://docs.microsoft.com/en-us/dotnet/framework/winforms/advanced/using-image-encoders-and-decoders-in-managed-gdi

predicates

    getMimeTypeFromDescription_dt : (string FileType) -> string MimeType determ.

    ensureValidDecoderDescrip_dt : (string) -> string ValidEncoderDescriptor determ.
    warnInvalidDecoder_CS_dt : (string Decoder_CaseSensitiveUC) determ. % requires input of UPPER CASE string

    warnInvalidEncoder_CS_dt : (string Encoder_CaseSensitiveUC) determ. % requires input of UPPER CASE string
    ensureValidEncoderDescrip_dt : (string) -> string ValidEncoderDescriptor determ.

    getDecoderFileMask_dt : (string FormatDescription) -> string ImageFileMask determ.
    % A string of semi-colon separated file extensions
    codecDecoderFormatList : () -> string_list FormatDescriptions.
    % Queries system for gdip_decoderList strings.

    getEncoderFileMask_dt : (string FormatDescription) -> string ImageFileMask determ.
    % A string of semi-colon separated file extensions
    codecEncoderFormatList : () -> string_list FormatDescriptions.
    % Queries system for gdip_encoderList strings.

    showCodecEncodersAndDecoders : ().
	% Display encoders and decoders in Messages window

end class gdipTools

/******************************************************************************

The IMAGE class is an abstract class from which BITMAPs and METAFILEs are descended.

    ENCODERS covert an IMAGE object to specific disk FILE type, e.g. BMP, GIF, etc.
    DECODERS convert an specific disk FILE type back to an IMAGE object.

IMAGE DECODERS (disk FILE to IMAGE):
CODEC Names         Format Descriptions FILE Extensions         MIME Types
Built-in BMP Codec  BMP             *.BMP;*.DIB;*.RLE           image/bmp
Built-in JPEG Codec JPEG            *.JPG;*.JPEG;*.JPE;*.JFIF   image/jpeg
Built-in GIF Codec  GIF             *.GIF                       image/gif
Built-in EMF Codec  EMF             *.EMF                       image/x-emf
Built-in WMF Codec  WMF             *.WMF                       image/x-wmf
Built-in TIFF Codec TIFF            *.TIF;*.TIFF                image/tiff
Built-in PNG Codec  PNG             *.PNG                       image/png
Built-in ICO Codec  ICO             *.ICO                       image/x-icon



IMAGE ENCODERS (IMAGE to disk FILE):
CODEC Names     Format Descriptions FILE Extensions             MIME Types
Built-in BMP Codec  BMP             *.BMP;*.DIB;*.RLE           image/bmp
Built-in JPEG Codec JPEG            *.JPG;*.JPEG;*.JPE;*.JFIF   image/jpeg
Built-in GIF Codec  GIF             *.GIF                       image/gif
Built-in TIFF Codec TIFF            *.TIF;*.TIFF                image/tiff
Built-in PNG Codec  PNG             *.PNG                       image/png

imageCodecInfo = imageCodecInfo(
        nativeGuid Id,
        nativeGuid FormatId,
        string CodecName,
        string DllName,
        string FormatDescription,
        string FileNameExtension,
        string MimeType,
        unsigned Flags,
        unsigned Version,
        unsigned SigCount,
        unsigned SigSize,
        pointer SigPattern_ByteArray,
        pointer SigMask_ByteArray).

See this for more info:
Graphics Programming with GDI+ by Mahesh Chand
            Addison Wesley
            Microsoft .NET Development Series
            2004

Also, see:
https://books.google.com/books?id=ElAaTGP__U0C&pg=PA384&lpg=PA384&dq=gdiplus+image+encode+decode&source=bl&ots=AjzZU9fYwG&sig=s_rjJod4HTi1iZ9WUzAdqRWzDpk&hl=en&sa=X&ved=0ahUKEwjenfSb9LvVAhWK34MKHcbOBYQQ6AEITzAG#v=onepage&q=gdiplus%20image%20encode%20decode&f=false

https://docs.microsoft.com/en-us/dotnet/framework/winforms/advanced/using-image-encoders-and-decoders-in-managed-gdi

******************************************************************************/
%
