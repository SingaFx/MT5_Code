//+------------------------------------------------------------------+
//|                                   EA_TranularArbOnChartEvent.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
input string Inp_symbol_x="EURUSD";
input string Inp_symbol_y="GBPUSD";
input string Inp_symbol_xy="EURGBP";
input double Inp_lots=0.1;
input int Inp_dev_points=50;
input double Inp_win_per_lots=50;
input int ea_magic=8800;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(iCustom(Inp_symbol_x,PERIOD_M1,"iSpy",ChartID(),0)==INVALID_HANDLE) 
      { Print("Error in setting of spy on ",Inp_symbol_x); return(true);}
   if(iCustom(Inp_symbol_y,PERIOD_M1,"iSpy",ChartID(),1)==INVALID_HANDLE) 
      { Print("Error in setting of spy on ",Inp_symbol_y); return(true);}
   if(iCustom(Inp_symbol_xy,PERIOD_M1,"iSpy",ChartID(),2)==INVALID_HANDLE) 
      { Print("Error in setting of spy on ", Inp_symbol_xy); return(true);}
      
   Print("Spys ok, waiting for data...");
   //---
   return(0);
   
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
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id>=CHARTEVENT_CUSTOM)      
     {
      Print(TimeToString(TimeCurrent(),TIME_SECONDS)," -> id=",id-CHARTEVENT_CUSTOM,":  ",sparam," ",EnumToString((ENUM_TIMEFRAMES)lparam)," price=",dparam);
      switch(sparam)
        {
         case Inp_symbol_x:
           
           break;
         default:
           break;
        }
     
     }
  }
//+------------------------------------------------------------------+
