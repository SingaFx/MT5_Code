//+------------------------------------------------------------------+
//|                                               S_DownloadData.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\NewBarDetector.mqh>

input datetime Inp_begin=D'2017.01.01';
input datetime Inp_end=D'2018.01.01';

string f_name;
int f_handle;
CBarDetector bar_detector=new CBarDetector(_Symbol,_Period);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   f_name=_Symbol+"_from_"+TimeToString(Inp_begin,TIME_DATE)+"_to_"+TimeToString(Inp_end,TIME_DATE)+"_"+PeriodFlag(_Period);
   StringReplace(f_name,".","");
   f_handle=FileOpen("Data\\"+f_name+".txt",FILE_WRITE|FILE_CSV);
   if(f_handle==INVALID_HANDLE)
      {
       Print(false);
       return(INIT_FAILED);
      }
      
   FileWrite(f_handle, "date_time","open","high","low","close","real_volume","tick_volume","spread");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //FileClose(f_handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(bar_detector.IsNewBar())
     {
      MqlRates rates[];
      CopyRates(_Symbol,_Period,0,2,rates);
      Print(rates[0].time,rates[0].open," ",rates[0].high," ",rates[0].low," ",rates[0].close," ",rates[0].real_volume," ",rates[0].tick_volume," ",rates[0].spread);
      FileWrite(f_handle, rates[0].time,rates[0].open,rates[0].high,rates[0].low,rates[0].close,rates[0].real_volume,rates[0].tick_volume,rates[0].spread);
     }
  }
//+------------------------------------------------------------------+
string PeriodFlag(ENUM_TIMEFRAMES period)
   {
    string tf_flag;
    switch(period)
      {
       case PERIOD_M1:
         tf_flag="M1";
         break;
       case PERIOD_H1:
          tf_flag="H1";
          break;
       case PERIOD_D1:
          tf_flag="D1";
          break;
       default:
         tf_flag="Unknown";
         break;
      }
     return tf_flag;
   }