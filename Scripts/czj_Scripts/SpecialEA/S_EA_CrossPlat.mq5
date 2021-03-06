//+------------------------------------------------------------------+
//|                                               S_EA_CrossPlat.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <strategy_czj\special\PipeCrossPlat.mqh>
input string Inp_pipe_name="pipe1";
input ulong Inp_magic=61805002;
input double Inp_lots=0.2;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   CPipeCrossPlat *arb_pipe= new CPipeCrossPlat();
   arb_pipe.ConnectedToServer(Inp_pipe_name);
   arb_pipe.SetMagic(Inp_magic);
   arb_pipe.SetLots(Inp_lots);
   arb_pipe.Run();
  }
//+------------------------------------------------------------------+
