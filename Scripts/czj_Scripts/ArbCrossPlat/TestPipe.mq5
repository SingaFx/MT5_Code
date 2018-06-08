//+------------------------------------------------------------------+
//|                                                     TestPipe.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\special\PipeTest.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#property script_show_inputs
input string symbol_enable="1,1,1,1,1,1,1";//GBPUSD,EURUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY

string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};

void OnStart()
  {
//---
   CPipeTest test = new CPipeTest();
   test.ConnectedToServer("pipe1");
   //test.SendIndex();
   //test.SendIndex();
   //test.SendDouble();
   //test.SendTickData();
    //test.SendLong();
    //test.SendLong();
    while(!IsStopped())
      {
        test.EventHandle();
      }
    //test.SendTest();
  }
//+------------------------------------------------------------------+
