/* 24/02/05 */


#ifndef FIL_TYP
#define FIL_TYP

/* char FIL_TADirFilesList [FIL_DIR_FILES_LIST_MAX_CNT][GLB_FILE_PATH_SZ]; */


typedef struct {
  char AList [FIL_DIR_FILES_LIST_MAX_CNT][GLB_FILE_PATH_SZ];
} FIL_TDirFilesList;


// 30/01/2009

class FIL__TCBinFile {
  
  
  private :

  protected :
  
    SInt8 ProConfDone; // -1 => not done / +1 => done / 0 IS NOT allowed
    
    // Parameters from constructor
    
    char  ProParErrLogFile[GLB_FILE_PATH_SZ];
    SInt8 ProParEnableErrLog;
    SInt8 ProParErrLogLvl;
  
    // Parameters from conf
    
    char   ProParDataFile[GLB_FILE_PATH_SZ];
    SInt8  ProParRWBMode;
    SInt32 ProParMaxBlocSz;
    SInt32 ProParBlocSz;
    SInt8  ProParFlushAfterWrite;
    SInt8  ProParMeasTime;
    
    // Variables for internal processing

    SInt8  ProReadyToWrite; // -1 no / +1 yes / 0 IS NOT allowed
    SInt8  ProReadyToRead;  // -1 no / +1 yes / 0 IS NOT allowed
    
    SInt32 ProCurRdEltId;
    SInt32 ProCurRdSz;
    
    SInt32 ProCurWrEltId;
    UInt64 ProCurWrSz;      // Moved from SInt32 to UInt64 on 08/11/2010
    UInt64 ProTotWrSz;      // Moved from SInt32 to UInt64 on 08/11/2010
    
    void*  ProPtrBuffRdData;
    SInt32 ProSzBuffRdData;
    
    FILE*  ProPtFile;
    
    UInt32 ProTime1;
    UInt32 ProTime2;
    UInt32 ProTimeExec;
    
  
  
  public :
  
     FIL__TCBinFile ( char* ErrLogFile, SInt8 EnableErrLog, SInt8 ErrLogLvl );
    ~FIL__TCBinFile ();
    
    SInt32 PubFBegin ( char* ErrLogFile, SInt8 EnableErrLog, SInt8 ErrLogLvl );
    SInt32 PubFConf  ( char* DataFile, SInt8 RWBMode, SInt32 MaxBlocSz, SInt32 BlocSz, SInt8 FlushAfterWrite, SInt8 MeasTime );
    
    SInt32 PubFSetFileName  ( char* DataFile );
    SInt32 PubFSetFlushMode ( SInt8 FlushAfterWrite );
    
    SInt32 PubFGetFileSz  ();
    SInt32 PubFGetBlocNb  ();
    
    
    SInt32 PubFCreate ();
    SInt32 PubFOpen ();
    SInt32 PubFSeqWrite  ( void* PtrData, SInt32 DataSz );
    SInt32 PubFSeqRead   ( void* DestPtr, SInt32 MaxDestSz, SInt32 DataSzToRead );
    void*  PubFSeqRead   ( SInt32 DataSzToRead );
    SInt32 PubFGotoBloc  ( SInt32 BlocNo );
    SInt32 PubFBlocRead  ( SInt32 BlocNo, void* DestPtr, SInt32 MaxDestSz );
    void*  PubFBlocRead  ( SInt32 BlocNo );
    SInt32 PubFFlush ();
    SInt32 PubFClose ();
  
};


// 01/05/2010

typedef struct {
  
  SInt32        Version;
  TIME__TUDateL DateCreate;
  TIME__TUTime  TimeCreate;
  TIME__TUDateL DateClose;
  TIME__TUTime  TimeClose;
  SInt32        FixedBlocSz;
  UInt32        MaxBlocSz;
  UInt32        BlocSz;
  UInt32        BlocNb;
  UInt32        ABlocSz[1];
  
} FIL__TCStreamFile_Old_TRecInfFile;

// 05/11/10

typedef struct {
  
  UInt64 Offset;
  UInt32 Sz;
  SInt32 SpareW32Info;
  
} FIL__TCStreamFile_TBlocInf;


// 05/11/10

typedef struct {
  
  SInt32        Version;
  TIME__TUDateL DateCreate;
  TIME__TUTime  TimeCreate;
  TIME__TUDateL DateClose;
  TIME__TUTime  TimeClose;
  SInt32        FixedBlocSz;
  UInt32        MaxBlocSz;
  UInt32        BlocSz;
  UInt32        BlocNb;
  FIL__TCStreamFile_TBlocInf ABlocInf[1];
  
} FIL__TCStreamFile_TRecInfFile;


class FIL__TCStreamFile {
  
  
  private :
  
    FIL__TCStreamFile* PriPtMyself;
    
  protected :
  
    SInt8 ProConfDone; // -1 => not done / +1 => done / 0 IS NOT allowed
    
    // Parameters from constructor
    
    char   ProParErrLogFile[GLB_FILE_PATH_SZ];
    SInt8  ProParEnableErrLog;
    SInt8  ProParErrLogLvl;
    SInt32 ProParDiskBlocSz;
    SInt8  ProParFixedBlocSzMode;
    
    // Parameters from conf
    
    SInt8  ProUseThread;
    char   ProParDataFile[GLB_FILE_PATH_SZ];
    SInt8  ProParRWBMode;
    SInt32 ProParRequestedMaxBlocSz; // Bloc size value asked by user
    SInt32 ProParMaxBlocSz;          // Adjusted depending on ProParBlocSz
    
    SInt32 ProParRequestedBlocSz;   // Bloc size value asked by user
    SInt32 ProParBlocSz;            // Bloc size value used ( multiple of disk bloc size ) 
    SInt8  ProParFlushAfterWrite;
    SInt8  ProParMeasTime;
    
    // Variables for internal processing

    HANDLE ProFileHnd;

    char   ProInfFileName[GLB_FILE_PATH_SZ];
    FILE*  ProPtInfFile;
    
    FIL__TCStreamFile_TRecInfFile* ProPtRecInfFile;
    SInt32                         ProRecInfSz;
    
    SInt8  ProReadyToWrite; // -1 no / +1 yes / 0 IS NOT allowed
    SInt8  ProReadyToRead;  // -1 no / +1 yes / 0 IS NOT allowed
    
#ifndef CC_UNIX
    CRITICAL_SECTION ProCsPrintMsg;
#endif

    HANDLE ProThreadHnd;
    DWORD  ProThreadId;
  
    HANDLE ProSemWrBuffHnd;
    HANDLE ProSemRdBuffHnd;
    
    SInt16 ProIndexWrBuff;
    SInt16 ProIndexRdBuff;
    
    UInt8* ProABuff[FIL__TCStreamFile_MAX_BUFF_NB];
    SInt32 ProBuffSz;
  
    
    SInt32 ProCurRdBlocId;
    SInt32 ProCurRdSz;
    
    SInt32 ProCurWrBlocId;
    SInt32 ProCurWrSz;
    
    // SInt32 ProTotWrSz;

    SInt64 ProTotWrSz;
    

    void*  ProPtrBuffRdData;
    SInt32 ProSzBuffRdData;
      
    UInt32 ProTime1;
    UInt32 ProTime2;
    UInt32 ProTimeExec;
    
    // Results
    
    SInt32 ProResWrBlocFailCnt;
    
    SInt32 ProFCalcProParBlocSz ( SInt32 DataSz );
  
  public :
  
    FIL__TCStreamFile ( char* ErrLogFile, SInt8 EnableErrLog, SInt8 ErrLogLvl, SInt32 DiskBlocSz );
    ~FIL__TCStreamFile ();
    
    friend DWORD WINAPI FIL__TCStreamFile_FThread (  LPVOID lpParam );
    
    SInt32 PubFBegin    ( char* ErrLogFile, SInt8 EnableErrLog, SInt8 ErrLogLvl, SInt32 DiskBlocSz );
    void   PubFPrintMsg ( char* Msg );
    SInt32 PubFConf     ( FIL__TCStreamFile* PtMyself, SInt8 UseThread, char* DataFile, SInt8 RWBMode, SInt8 FixedBlocSzMode, SInt32 MaxBlocSz, SInt32 BlocSz, SInt8 FlushAfterWrite, SInt8 MeasTime );
    
    SInt32 PubFSetFileName  ( char* DataFile );
    SInt32 PubFSetFlushMode ( SInt8 FlushAfterWrite );
    
    SInt32 PubFPrintInfFile ();
    SInt32 PubFGetFileSz  ();
    SInt32 PubFGetBlocNb  ();
    
    
    SInt32 PubFCreate ();
    SInt32 PubFOpen ();
    SInt32 PubFSeqWrite  ( void* PtrData, SInt32 DataSz, SInt32 SpareInfo );
    SInt32 PubFSeqRead   ( void* DestPtr, SInt32 MaxDestSz, SInt32 DataSzToRead );
    void*  PubFSeqRead   ( SInt32 DataSzToRead );
    SInt32 PubFGotoBloc  ( SInt32 BlocNo );
    SInt32 PubFBlocRead  ( SInt32 BlocNo, void* DestPtr, SInt32 MaxDestSz, SInt32* PtSpareW32Info );
    void*  PubFBlocRead  ( SInt32 BlocNo );
    SInt32 PubFFlush ();
    SInt32 PubFClose ();
    
};




#endif

