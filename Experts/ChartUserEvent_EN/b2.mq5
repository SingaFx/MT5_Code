//+------------------------------------------------------------------+
//|                                                           b2.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
//---


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   ENUM_CHART_EVENT eFirst_event_id,eLast_event_id;
   int nFirst_event_id,nLast_event_id;
   //---
   eFirst_event_id=CHARTEVENT_CUSTOM;
   nFirst_event_id=eFirst_event_id;
   eLast_event_id=CHARTEVENT_CUSTOM_LAST;
   nLast_event_id=eLast_event_id;
//---
   DebugBreak();
  }
//+------------------------------------------------------------------+
