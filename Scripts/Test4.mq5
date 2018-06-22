//+------------------------------------------------------------------+
//|                                                        Test4.mq5 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int arr[]={1,2,3,4,5,6,7,8,9};
   Print("max index:",ArrayMaximum(arr)," max value:", arr[ArrayMaximum(arr)]);
   
   Print("max index:",ArrayMaximum(arr,3,5)," max value:", arr[ArrayMaximum(arr,3,5)]);
  }
//+------------------------------------------------------------------+
