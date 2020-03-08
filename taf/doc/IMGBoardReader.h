#ifndef _IMGBoardReader_included_
#define _IMGBoardReader_included_

#include "Riostream.h"
#include "TObject.h"
#include "TMath.h"
//#include <iostream>
#include <fstream>
#include <vector>
#include <math.h>
#include "DGlobalTools.h" // to have fTool has a data member
#include "img_daq_lib/event_header.typ"

//using namespace std;


// --------------------------------------------------------------------------------------

class IMGPixel : public TObject {
  
  // Container for a simple pixel
  // only 3 values
  // JB, 2008/09/27
  // Modified: JB, 2013/06/19 include timestamp
  
private:
  
  int Input;
  int Value;
  int Index;
  int TimeStamp;
  
public:
  
  IMGPixel() {  Input = 0; Value = 0; Index = 0; TimeStamp = 0; }
  IMGPixel( int input, int value, int index) {  Input = input; Value = value; Index = index; TimeStamp = 0; }
  IMGPixel( int input, int value, int index, int time) {  Input = input; Value = value; Index = index; TimeStamp = time; }
  virtual ~IMGPixel() {;}
  int      GetInput()                 { return Input; }
  int      GetValue()                 { return Value; }
  int      GetIndex()                 { return Index; }
  int      GetTimeStamp()             { return TimeStamp; }
  
  ClassDef(IMGPixel,1)
};

// --------------------------------------------------------------------------------------

class IMGEvent : public TObject {

 private:

  int  EventNumber;
  int  BoardNumber;  
  vector<IMGPixel> *ListOfPixels;
  vector<int>      *ListOfTriggers;
  vector<int>      *ListOfTimestamps;
  vector<int>      *ListOfFrames;
  int              *RawDataArray;

 public:

  IMGEvent() {;}
  IMGEvent( int currentEventNumber, int boardNumber, vector<int> *ListOfTriggers, vector<int> *ListOfTimestamps, vector<int> *ListOfFrames, vector<IMGPixel> *ListOfPixels);
 ~IMGEvent();

  int               GetEventNumber()             { return EventNumber; }
  int               GetBoardNumber()             { return BoardNumber; }
  int               GetNumberOfPixels()          { return ListOfPixels->size(); }
  vector<IMGPixel> *GetPixels()                  { return ListOfPixels;}
  IMGPixel         *GetPixelAt( int index)       { return &(ListOfPixels->at(index)); }
  int               GetNumberOfTriggers()        { return ListOfTriggers->size(); }
  int               GetNumberOfTimestamps()      { return ListOfTimestamps->size(); }//RDM150509
  vector<int>      *GetTriggers()                { return ListOfTriggers;}
  vector<int>      *GetTimestamps()              { return ListOfTimestamps;} //RDM150509
  int               GetTriggerAt( int index)     { return ListOfTriggers->at(index);}
  int               GetTimestampAt( int index)   { return ListOfTimestamps->at(index);}//RDM150509
  int               GetNumberOfFrames()          { return ListOfFrames->size(); }
  vector<int>      *GetFrames()                  { return ListOfFrames;} //JB 2010/06/16
  int               GetFrameAt( int index)       { return ListOfFrames->at(index);}
  int              *GetRawDataArray()            { return RawDataArray;}
  //int              *GetRawDataArray( int anInput);

  ClassDef(IMGEvent,1)
};

// --------------------------------------------------------------------------------------

class IMGBoardReader : public TObject {

 private:

  int               DebugLevel;
  DGlobalTools      fTool;

  int               BoardNumber;
  int               NbOfInputs; // nb of inputs in this acquisition board
  int               SizeOfHeader;

  bool              ReadingEvent;
  Int_t             TriggerMode;
  IMGEvent         *CurrentEvent;
  int               CurrentEventNumber;
  int               CurrentTriggerNumber;
  int               CurrentFrameNumber;
  int               CurrentTimestamp;
  int               TriggerLine;
  vector<int>       ListOfTriggers;
  vector<int>       ListOfTimestamps;
  int               maxNumberOfTriggersPerEvent;
  vector<int>       ListOfFrames;
  vector<IMGPixel>  ListOfPixels;

  // management of input files
  ifstream          RawFileStream;
  char             *InputFileName;
  char**            ListOfInputFileNames;
  char*             PrefixFileName;
  char*             SuffixFileName;
  int               CurrentFileNumber;
  int               NumberOfFiles;
  int               BuffersRead;
  bool              NoMoreFile;
  int               EventsInFile; // JB 2012/08/18
  
  // management of data buffer
  size_t            SizeOfEvent; // nb of bytes in an event
  char             *Data;
  int               Endianness;       // 0= do not swap bytes, 1= swap bytes

  unsigned int      EventTrailer;
  TEventHeader     *EventHeader;

  // Parameteres to decode each input
  int               ifStripTelescope; // indicate if strip-telescope data
  int               ifMultiFrame; // indicate more than 2 frames per value
  int              *NbOfChannels; // nb of channels in one input
  int              *NumberOfBitsValue; // nb of bits encoding one value, may be several channels
  int              *SignificantBits; // nb of bits encoding one channel
  bool             *SignedValues;
  int              *InputDataAdress;
  unsigned int     *MaxSignedValue;
  size_t           *SizeOfInputData; // total nb of bytes for an input
  size_t           *SizeOfValue; // nb of bytes for one value for an input
  int              *NChannelsPerValue;
  int              *NValuesToRead;
  bool             *WithCDS; // if 2 values are encoded in one channel for CDS
  int              *NValuesPerChannel; // >1 if ifMultiFrame
  int              *NValuesToJumpPerChannel; // if ifMultiFrame
  int              *FirstExcludedChannel; // exclude some channels from analysis
  int              *LastExcludedChannel; // JB 2013/06/22
  
  // Parameters to decode trigger info embedded in pixel data 
  double            triggerLowThreshold; // JB 2013/06/19
  double            triggerHighThreshold;
  int              *FirstTriggerChannel;
  int              *LastTriggerChannel;
  vector<int>       ListOfTriggersFromData;

  // For statistics
  int               EventsCount;
  int               FramesRead;


  bool         CloseRawFile();
  bool         OpenRawFile( char *fileName);
  bool         LookUpRawFile();
  bool         GetNextBuffer();
  bool         SetBufferPointers();
  void         GetInputData( int mode=0);
  void         GetTriggerData();
  int          DecodeTriggerFromData( int input, int rowNumber, unsigned int *rawdatas, int nFrames); // 2013/06/19
  unsigned int BuildValue( int anAddress, int wordSize );
  void         AddPixel( int input, unsigned int rawdata, int index);
  void         AddPixel( int input, unsigned int *rawdatas, int nFrames, int index); // JB 2013/06/19
  

  public:

  IMGBoardReader() {;}
  IMGBoardReader( int boardNumber, int nInputs, int *nChannels, int sizeOfEvent, int eventsInFile, int headerSize, int *numberOfBits, int *sigBits, int endian=0, int triggermode=0, int daqmode=0);
  ~IMGBoardReader();
  void         SetDebugLevel( int level)              { DebugLevel = level; cout << "IMGBoardReader " << BoardNumber << " debug updated to " << DebugLevel << endl;}
  void         SetEndiannes( int endian)              { Endianness = endian; }
  bool         AddFile(char *inputFileName);
  bool         AddFileList(char *prefixFileName, int startIndex, int endIndex, char *suffixFileName);
  bool         HasData();
  void         SkipNextEvent();
  int          GetBoardNumber()                       { return BoardNumber; }
  IMGEvent*    GetEvent()                             { return CurrentEvent; }
  int          GetEventNumber()                       { return CurrentEventNumber;}
  char*        GetInputFileName()                     { return InputFileName;}
  char*        GetSuffixFileName()                    { return SuffixFileName;}
  char*        GetPrefixFileName()                    { return PrefixFileName;}
  void         PrintEventHeader();
  void         PrintStatistics(ostream &stream=cout);
  void         DumpEventHeaders( int nFrames);
  

  ClassDef(IMGBoardReader,1);  
};

# endif
