//+------------------------------------------------------------------+
//|                                             EA_Ticks_ByTimer.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>
input string pipe_tick="pipe_tick1";

string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
CFilePipe  PipeTick;
MqlTick tick;
int ask;
int bid;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
// 连接tick数据传输的管道
   if(PipeTick.Open("\\\\REN\\pipe\\"+pipe_tick,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeTick.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("成功与服务器tick数据传输管道连接成功！");
      return(INIT_SUCCEEDED);
     }
   if(PipeTick.Open("\\\\.\\pipe\\"+pipe_tick,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeTick.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("成功与服务器tick数据传输管道连接成功！");
      return(INIT_SUCCEEDED);
     }
   Print("与服务器tick数据传输管道连接失败！");
//---
   return(INIT_FAILED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   for(int i=0;i<ArraySize(symbols);i++)
     {
      SymbolInfoTick(symbols[i],tick);
      ask=tick.ask/SymbolInfoDouble(symbols[i],SYMBOL_POINT);
      bid=tick.bid/SymbolInfoDouble(symbols[i],SYMBOL_POINT);
//       发送数据至服务器
      PipeTick.WriteInteger(i);
      PipeTick.WriteInteger(ask);
      PipeTick.WriteInteger(bid);
     }
   
  }
//+------------------------------------------------------------------+
