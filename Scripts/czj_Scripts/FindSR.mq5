//+------------------------------------------------------------------+
//|                                                       FindSR.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\common\czj_function.mqh>
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   GetValue();
  }
void GetValue()
   {
    ObjectsDeleteAll(0);
    int num_control=40;
    MqlRates rates[];
    CopyRates(_Symbol,_Period,0,1000,rates);
    double high_price[],low_price[];
    CopyHigh(_Symbol,_Period,0,1000,high_price);
    CopyLow(_Symbol,_Period,0,1000,low_price);
    CArrayDouble support;
    CArrayDouble resistance;
    for(int i=num_control;i<1000-num_control;i++)
      {
       if(IsMaxLeftRight(high_price,i,num_control,num_control)) resistance.Add(high_price[i]);
       if(IsMinLeftRight(low_price,i,num_control,num_control)) support.Add(low_price[i]);
      }
    for(int i=0;i<support.Total();i++) 
      {
       Print("支撑位置:",support.At(i));
       ObjectCreate(0,"support-"+IntegerToString(i),OBJ_HLINE,0,0,support.At(i));
       ObjectSetInteger(0,"support-"+IntegerToString(i),OBJPROP_COLOR,clrBlue);
      }
    for(int i=0;i<resistance.Total();i++)
     {
      Print("阻力位置:",resistance.At(i));    
      ObjectCreate(0,"resistance-"+IntegerToString(i),OBJ_HLINE,0,0,resistance.At(i));
      ObjectSetInteger(0,"resistance-"+IntegerToString(i),OBJPROP_COLOR,clrRed);
     }
     
   }  
//+------------------------------------------------------------------+
