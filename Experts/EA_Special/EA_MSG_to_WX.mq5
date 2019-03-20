//+------------------------------------------------------------------+
//|                                                 EA_MSG_to_WX.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

string msg;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   msg="hello";
   Print(msg);
   int f_handle=FileOpen("test.csv",FILE_WRITE|FILE_CSV);
   if(f_handle!=INVALID_HANDLE)
     {
      FileWrite(f_handle,msg);
      FileClose(f_handle);
     }   
  }
//+------------------------------------------------------------------+
