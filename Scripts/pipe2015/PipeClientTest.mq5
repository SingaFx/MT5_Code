//+------------------------------------------------------------------+
//|                                                   PipeClient.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Files\FilePipe.mqh>

CFilePipe  ExtPipe;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- wait for pipe server
   while(!IsStopped())
     {
      if(ExtPipe.Open("\\\\REN\\pipe\\MQL5.Pipe.Server",FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) break;
      if(ExtPipe.Open("\\\\.\\pipe\\MQL5.Pipe.Server",FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) break;
      Sleep(250);
     }
   Print("Client: pipe opened");
//--- send welcome message
   if(!ExtPipe.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
     {
      Print("Client: sending welcome message failed");
      return;
     }
//--- read data from server
   string        str;
   int           value=0;

   if(!ExtPipe.ReadString(str))
     {
      Print("Client: reading string failed");
      return;
     }
   Print("Server: ",str," received");

   if(!ExtPipe.ReadInteger(value))
     {
      Print("Client: reading integer failed");
      return;
     }
   Print("Server: ",value," received");
//--- send data to server
   if(!ExtPipe.WriteString("Test string"))
     {
      Print("Client: sending string failed");
      return;
     }

   if(!ExtPipe.WriteInteger(value))
     {
      Print("Client: sending integer failed");
      return;
     }
   ExtPipe.Close();
  }
//+------------------------------------------------------------------+
