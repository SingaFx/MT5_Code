//+------------------------------------------------------------------+
//|                                                 TestPipeBase.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#include <strategy_czj\special\PipeBase.mqh>

input string Inp_PipeName="pipe1";// 管道名称
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Print(sizeof(OpenPositionResult));
   CPipeBase pb = new CPipeBase();
   bool is_connected=pb.ConnectedToServer(Inp_PipeName);
   while(!IsStopped()&&is_connected)
     {
      pb.EventHandle();
     }
  }
//+------------------------------------------------------------------+
