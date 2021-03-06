//+------------------------------------------------------------------+
//|                                                  EA_PipeTest.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Files\FilePipe.mqh>

CFilePipe  ExtPipe;
MqlTick latest_price;
int file_type  = FILE_BIN;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  while(!IsStopped())
     {
      if(ExtPipe.Open("\\\\REN\\pipe\\MQL5.Pipe.Server",FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) break;
      if(ExtPipe.Open("\\\\.\\pipe\\MQL5.Pipe.Server",FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) break;
      //if(ExtPipe.Open("\\\\REN\\pipe\\test_pipe",FILE_READ|FILE_WRITE|file_type)!=INVALID_HANDLE) break;
      //if(ExtPipe.Open("\\\\.\\pipe\\test_pipe",FILE_READ|FILE_WRITE|file_type)!=INVALID_HANDLE) break;
      Sleep(250);
     }
   Print("Client: pipe opened");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   SymbolInfoTick(_Symbol,latest_price);
   //Print("tick price:","ask:",latest_price.ask," bid:",latest_price.bid, " 点差:",(latest_price.ask-latest_price.bid)/SymbolInfoDouble(_Symbol,SYMBOL_POINT));
   string to_server=__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__);
   string price_infor="品种-"+_Symbol+" time"+string(latest_price.time)+" ask:"+string(latest_price.ask)+" bid:"+string(latest_price.bid);
   if(!ExtPipe.WriteString(price_infor))
     {
      Print("Client: sending welcome message failed");
      return;
     }
   string        str;
   if(!ExtPipe.ReadString(str))
     {
      Print("Client: reading string failed");
      return;
     }
   //if(!ExtPipe.WriteInteger(1))
   //   {
   //    Print("sending value failed");
   //   }
   
//   string        str;
//   int           value=0;
//
//   if(!ExtPipe.ReadString(str))
//     {
//      Print("Client: reading string failed");
//      return;
//     }
//   Print("Server: ",str," received");
//   
//   if(!ExtPipe.ReadInteger(value))
//     {
//      Print("Client: reading integer failed");
//      return;
//     }
//   Print("Server: ",value," received");
   //test(); 
   
  }
//+------------------------------------------------------------------+
void test()
   {
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


//--- benchmark
//   double buffer[];
//   double volume=0.0;
//
//   if(ArrayResize(buffer,1024*1024,0)==1024*1024)
//     {
//      uint  ticks=GetTickCount();
//      //--- read 8 Mb * 128 = 1024 Mb from server
//      for(int i=0;i<128;i++)
//        {
//         uint items=ExtPipe.ReadArray(buffer);
//         if(items!=1024*1024)
//           {
//            Print("Client: benchmark failed after ",volume/1024," Kb, ",items," items received");
//            break;
//           }
//         //--- check the data
//         if(buffer[0]!=i || buffer[1024*1024-1]!=i+1024*1024-1)
//           {
//            Print("Client: benchmark invalid content");
//            break;
//           }
//         //---
//         volume+=sizeof(double)*1024*1024;
//        }
//      //--- send confirmation
//      value=12345;
//      if(!ExtPipe.WriteInteger(value))
//         Print("Client: benchmark confirmation failed ");
//      //--- show statistics
//      ticks=GetTickCount()-ticks;
//      if(ticks>0)
//         printf("Client: %.0lf Mb received at %.0lf Mb per second\n",volume/1024/1024,volume/1024/ticks);
//      //---
//      ArrayFree(buffer);
//     }
   }