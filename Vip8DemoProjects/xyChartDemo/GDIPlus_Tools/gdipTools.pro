% Copyright 2018 Harrison Pratt

implement gdipTools

    open core, string, gdiplus

%class predicates
%    ensureValidEncoderDescrip_dt : (string) -> string ValidEncoderDescriptor determ.
clauses
    ensureValidEncoderDescrip_dt(TryEncoder) = EncoderDescriptor :-
        EncoderDescriptor in gdip_encoderList,
        EncoderDescriptor = toUpperCase(TryEncoder),
        !.
    ensureValidEncoderDescrip_dt(S) = _ :-
        vpiCommonDialogs::error(predicate_fullname(), format("'%' is not a valid encoder descriptor.", S)),
        fail.

%class predicates
%    ensureValidDecoderDescrip_dt : (string) -> string ValidEncoderDescriptor determ.
clauses
    ensureValidDecoderDescrip_dt(TryDecoder) = EncoderDescriptor :-
        EncoderDescriptor in gdip_decoderList,
        EncoderDescriptor = toUpperCase(TryDecoder),
        !.
    ensureValidDecoderDescrip_dt(S) = _ :-
        vpiCommonDialogs::error(predicate_fullname(), format("'%' is not a valid encoder descriptor.", S)),
        fail.

%class predicates
%    getMimeTypeFromDescription_dt : (string FileType) -> string MimeType determ.
clauses
    getMimeTypeFromDescription_dt(FType) = MimeType :-
        fType_mType(FType, MimeType),
        string::equalIgnoreCase(FType, MimeType),
        !.

class predicates
    fType_mType : (string FType, string MimeType [out]) determ.
clauses
    % fType_mType("Format Descriptions","MIME Type").
    fType_mType("BMP", "image/bmp").
    fType_mType("JPEG", "image/jpeg").
    fType_mType("GIF", "image/gif").
    fType_mType("EMF", "image/x-emf").
    fType_mType("WMF", "image/x-wmf").
    fType_mType("TIFF", "image/tiff").
    fType_mType("PNG", "image/png").
    fType_mType("ICO", "image/x-icon").

%class predicates
%    warnInvalidEncoder_CS_dt : (string EncoderUC) determ. % expects input of UPPER CASE string
%    % expects input of UPPER CASE string
clauses
    warnInvalidEncoder_CS_dt(Enc) :-
        Enc in gdip_encoderList,
        !.
    warnInvalidEncoder_CS_dt(Enc) :-
        vpiCommonDialogs::error(predicate_fullname(),
            string::format("'%' is not a valid encoder.\n\nValid encoders: %", Enc, toString(gdip_encoderList))),
        fail.

%class predicates
%    warnInvalidDecoder_CS_dt : (string EncoderUC) determ. % expects input of UPPER CASE string
clauses
    warnInvalidDecoder_CS_dt(Enc) :-
        Enc in gdip_decoderList,
        !.
    warnInvalidDecoder_CS_dt(Enc) :-
        vpiCommonDialogs::error(predicate_fullname(),
            string::format("'%' is not a valid decoder.\n\nValid decoders: %", Enc, toString(gdip_decoderList))),
        fail.

clauses
    showCodecEncodersAndDecoders() :-
        GdiPlusToken = gdiplus::startup(),
        stdio::write("\n\n\nIMAGE DECODERS (disk file to IMAGE):\n"),
        FmtStr = "%-20s\t%-20s\t%-28s\t%\n",
        stdio::writef(FmtStr, "CODEC Name", "Format Descriptions", "File Extensions", "MIME Type"),
        DecoderList = gdiplus::imageDecoders,
        foreach E = list::getMember_nd(DecoderList) do
            E = imageCodecInfo(_Id, _FormatID, CodecName, _DllName, FormatDescrip, FileExt, MimeType, _Flags, _Version, _SigCount, _SigSize, _P1, _P2),
            stdio::writef(FmtStr, CodecName, FormatDescrip, FileExt, MimeType)
        end foreach,

        stdio::write("\n\n\nIMAGE ENCODERS (IMAGE to disk file):\n"),
        stdio::writef(FmtStr, "CODEC Name", "Format Descriptions", "File Extensions", "MIME Type"),
        EncoderList = gdiplus::imageEncoders,
        foreach E = list::getMember_nd(EncoderList) do
            E = imageCodecInfo(_Id, _FormatID, CodecName, _DllName, FormatDescrip, FileExt, MimeType, _Flags, _Version, _SigCount, _SigSize, _P1, _P2),
            stdio::writef(FmtStr, CodecName, FormatDescrip, FileExt, MimeType)
        end foreach,
        gdiplus::shutdown(GdiPlusToken).

    codecEncoderFormatList() = SS :-
        GdiPlusToken = gdiplus::startup(),
        EncoderList = gdiplus::imageEncoders,
        SS =
            [ FormatDescrip ||
                E in EncoderList,
                E =
                    imageCodecInfo(_Id, _FormatID, _CodecName, _DllName, FormatDescrip, _FileExt, _MimeType, _Flags, _Version, _SigCount, _SigSize,
                        _P1, _P2)
            ],
        gdiplus::shutdown(GdiPlusToken).

    codecDecoderFormatList() = SS :-
        GdiPlusToken = gdiplus::startup(),
        EncoderList = gdiplus::imageDecoders,
        SS =
            [ FormatDescrip ||
                Enc in EncoderList,
                Enc =
                    imageCodecInfo(_Id, _FormatID, _CodecName, _DllName, FormatDescrip, _FileExt, _MimeType, _Flags, _Version, _SigCount, _SigSize,
                        _P1, _P2)
            ],
        gdiplus::shutdown(GdiPlusToken).

    getDecoderFileMask_dt(FormatDescrip) = FileExt :-
        GdiPlusToken = gdiplus::startup(),
        EncoderList = gdiplus::imageDecoders,
        if FileExt = tryGetCodecFileExt_CI(EncoderList, FormatDescrip) then
            gdiplus::shutdown(GdiPlusToken)
        else
            gdiplus::shutdown(GdiPlusToken),
            vpiCommonDialogs::error(predicate_fullname(), string::format("Invalid format description: %  ", FormatDescrip)),
            fail
        end if.

    getEncoderFileMask_dt(FormatDescrip) = FileExt :-
        GdiPlusToken = gdiplus::startup(),
        EncoderList = gdiplus::imageEncoders,
        if FileExt = tryGetCodecFileExt_CI(EncoderList, FormatDescrip) then
            gdiplus::shutdown(GdiPlusToken)
        else
            gdiplus::shutdown(GdiPlusToken),
            vpiCommonDialogs::error(predicate_fullname(), string::format("Invalid format description: %  ", FormatDescrip)),
            fail
        end if.

class predicates
    tryGetCodecFileExt_CI : (imageCodecInfo*, string FormatDescrip) -> string FileExtMask determ.
clauses
    tryGetCodecFileExt_CI(DecoderList, FormatDescrip) = FileExtMask :-
        FormatUC = string::toUpperCase(FormatDescrip),
        Enc in DecoderList,
        Enc = imageCodecInfo(_Id, _FormatID, _CodecName, _DllName, FormatUC, FileExtMask, _MimeType, _Flags, _Version, _SigCount, _SigSize, _P1, _P2),
        !.

end implement gdipTools
