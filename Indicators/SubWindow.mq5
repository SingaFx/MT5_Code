//+------------------------------------------------------------------+
//|                                                    SubWindow.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2016, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property indicator_separate_window
#property indicator_plots   0
#property indicator_buffers 0
#property indicator_minimum 0.0
#property indicator_maximum 0.0
//--- Program name
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
//--- Identifier of the event for changing the expert subwindow height
#define ON_SUBWINDOW_CHANGE_HEIGHT (38)
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- Short name of the indicator
   ::IndicatorSetString(INDICATOR_SHORTNAME,PROGRAM_NAME);
//--- Initialization successful
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int    rates_total,
                const int    prev_calculated,
                const int    begin,
                const double &price[])
  {
//--- If the initialization succeeded
   if(prev_calculated<1)
      //--- Send the message to the expert to get the subwindow size from it
      ::EventChartCustom(0,ON_SUBWINDOW_CHANGE_HEIGHT,0,0.0,PROGRAM_NAME);
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- Handling the event of changing the expert subwindow height
   if(id==CHARTEVENT_CUSTOM+ON_SUBWINDOW_CHANGE_HEIGHT)
     {
      //--- Accept messages only from the expert name
      if(sparam==PROGRAM_NAME)
         return;
      //--- Change the subwindow height
      ::IndicatorSetInteger(INDICATOR_HEIGHT,(int)lparam);
      //--- Refresh the chart
      ::ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
