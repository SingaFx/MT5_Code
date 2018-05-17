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

string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};

string f_name;
int f_handle;

CBarDetector bar_detector=new CBarDetector(_Symbol,_Period);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   f_name="BarData_from_"+TimeToString(Inp_begin,TIME_DATE)+"_to_"+TimeToString(Inp_end,TIME_DATE)+"_"+EnumToString(_Period);
   StringReplace(f_name,".","");
   f_handle=FileOpen("Data\\"+f_name+".txt",FILE_WRITE|FILE_CSV);
   if(f_handle==INVALID_HANDLE)
      {
       Print(false);
       return(INIT_FAILED);
      }
   FileWrite(f_handle, "DateTime",symbols[0],symbols[1],symbols[2],symbols[3],symbols[4],symbols[5],symbols[6]);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   FileClose(f_handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(bar_detector.IsNewBar())
     {
      datetime time[];
      double prices[7];
      CopyTime(_Symbol,_Period,0,1,time);
      for(int i=0;i<7;i++)
        {
         double price[];
         CopyClose(symbols[i],_Period,0,1,price);
         prices[i]=price[0];
        }
      FileWrite(f_handle, time[0],prices[0],prices[1],prices[2],prices[3],prices[4],prices[5],prices[6]);
     }
  }
//+------------------------------------------------------------------+
