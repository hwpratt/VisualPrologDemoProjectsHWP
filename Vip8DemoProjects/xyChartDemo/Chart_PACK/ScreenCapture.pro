% Copyright 2017 Harrison Pratt

implement screenCapture

    open core, bitmap, cryptography, exception, file, fileSystem_api, gdiplus
	open iStream_api, memory, memory_native, string, vpi, vpiCommonDialogs, vpiDomains

    open gdipTools

/******************************************************************************
                    SCREEN CAPTURE CODE
******************************************************************************/
clauses

    getClientBmp(W) = BMP :-
        WinVPI = W:getVpiWindow(),
        Pic = vpi::pictGetFromWin(WinVPI, vpi::winGetClientRect(WinVPI)),
        FileTEMP = file::createUniqueName(fileSystem_api::getTempPath(), "bmp"),
        vpi::pictSave(Pic, FileTEMP),
        BMP = bitmap::createFromFile(FileTEMP).  % NOTE: FileTEMP is LOCKED for the entire lifetime of image object

    clientWin_saveAsFile(W, QFN, Enc) :-
        WinVPI = W:getVpiWindow(),
        Pic = vpi::pictGetFromWin(WinVPI, vpi::winGetClientRect(WinVPI)),
        savePictureToFile(Pic, QFN, Enc).

    clientWin_putClipboardBMP(W) :-
        WinVPI = W:getVpiWindow(),
        Pic = vpi::pictGetFromWin(WinVPI, vpi::winGetClientRect(WinVPI)),
        cbPutPicture(Pic).

/******************************************************************************
    Kari Rastas code with minor modifications by hwp
        http://discuss.visual-prolog.com/viewtopic.php?t=15519&sid=ea9f13294db27a2156a167741afc202b
******************************************************************************/
clauses
    savePictureToFile(PIC, FileName, TryEncoder) :-
        EncoderStr = ensureValidEncoderDescrip_dt(TryEncoder), % force to upper-case if in list of valid encoders
        !,
        GdiPlusToken = gdiplus::startup(),
        gpPictToImage(PIC, Image),
        ImageClone = Image:clone(),
        Image:dispose(),
        gdiplus::imageCodecInfo(ImageTypeID, _, _, _, _, _, _, _, _, _, _, _, _) = getEncoder(EncoderStr, gdiplus::imageEncoders),
        ImageClone:saveToFile(FileName, ImageTypeID, []),
        ImageClone:dispose(),
        gdiplus::shutdown(GdiPlusToken),
        memory::garbageCollect().
    savePictureToFile(_, _, _).

clauses
    savePictureToFileJPEG(PIC, FileName) :-
        GdiPlusToken = gdiplus::startup(),
        gpPictToImage(PIC, Image),
        gdiplus::imageCodecInfo(JpegId, _, _, _, _, _, _, _, _, _, _, _, _) = getEncoder("JPEG", gdiplus::imageEncoders),
        Size = Image:getEncoderParameterListSize(JpegId),
        ParmList = Image:getEncoderParameterList(JpegId, Size),
        Image:saveToFile(FileName, JpegId, ParmList),
        Image:dispose(),
        gdiplus::shutdown(GdiPlusToken),
        _ = vpi::processEvents(),
        memory::garbageCollect().

class predicates
    getEncoder : (string FormatDescription, gdiplus::imageCodecInfo* EncoderList) -> gdiplus::imageCodecInfo Encoder.
clauses
    getEncoder(FormatDescription, [Encoder | _]) = Encoder :-
        gdiplus::imageCodecInfo(_, _, _, _, FormatDescription, _, _, _, _, _, _, _, _) = Encoder,
        !.
    getEncoder(FormatDescription, [_ | Rest]) = getEncoder(FormatDescription, Rest).
    getEncoder(FormatDescription, []) = _ :-
        exception::raise_errorf("Unsupported image format descriptor: '%'", FormatDescription).

class predicates
    gpPictToImage : (vpiDomains::picture Pict [in], image Image [out]).
clauses
    gpPictToImage(Pict, Image) :-
        PictBin = vpi::pictToBin(Pict),
        MemSize = binary::getSize(PictBin),
        HGlobal = memory_native::globalAlloc(memory_native::gmem_GHND, convert(unsigned, MemSize)),
        % GHND = GMEM_MOVEABLE + GMEM_ZEROINIT = 0x0002 + 0x0040
        Pointer = memory_native::globalLock(HGlobal),
        PointerBin = uncheckedConvert(pointer, PictBin),
        memory::copy(Pointer, PointerBin, MemSize),
        _ = iStream_api::createStreamOnHGlobal(HGlobal, 1, Stream), % hwp: https://msdn.microsoft.com/en-us/library/windows/desktop/aa378980(v=vs.85).aspx
        Image = image::createFromStream(Stream),
        _ = memory_native::globalUnlock(HGlobal).

clauses
    pictureFileToStringForHtml(PictureFile, Type, NameText, Width, Height) = PicStr :-
        file::existExactFile(PictureFile),
        BIN = cryptography::base64_encode(file::readBinary(PictureFile)),
        PicStr = string::format("\n<img src=\"data:image/%;base64,%s\" alt=\"%s\" width=\"%\" height=\"%\">\n", Type, BIN, NameText, Width, Height),
        !.
    pictureFileToStringForHtml(_PictureFile, _Type, _NameText, _Width, _Height) = "".

clauses
    pictureToStringForHtml(Pict, NameText, Width, Height) = PicStr :-
        savePictureToFile(Pict, "workpic.jpg", "jpeg"),
        pictureFileToStringForHtml("workpic.jpg", "jpeg", NameText, Width, Height) = PicStr.

end implement screenCapture
