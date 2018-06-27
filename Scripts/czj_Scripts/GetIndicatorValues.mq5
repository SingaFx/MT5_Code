//+------------------------------------------------------------------+
//|                                           GetIndicatorValues.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int file_handle=FileOpen("IndicatorValues\\"+_Symbol+"_"+EnumToString(_Period)+"_zigzag.csv",FILE_WRITE|FILE_CSV);
   if(file_handle==INVALID_HANDLE)
     {
      Print("invalid handle");
     }
   //FileWriteDouble(file_handle,1);
   //Print(FileWrite(file_handle,1));
   int handle = iCustom(_Symbol,_Period,"Examples\\ZigZag");
   double arr[];
   CopyBuffer(handle,0,0,10000,arr);
   
   
   for(int i=0;i<10000;i++)
     {
      //Print(arr[i]);
      if(arr[i]!=0) FileWrite(file_handle,arr[i]);
      //FileWriteArray(file_handle,arr);
     }
   
  }
//+------------------------------------------------------------------+
