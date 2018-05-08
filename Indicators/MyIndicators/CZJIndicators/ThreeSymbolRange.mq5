//+------------------------------------------------------------------+
//|                                      TwoSymbolCointergration.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1

input string Inp_Major_Symbol="EURUSD";
input string Inp_Minor_Symbol="USDCHF";
input string Inp_Cross_Symbol="EURCHF";

double price_range[];
double price_major_symbol[];
double price_minor_symbol[];
double price_cross_symbol[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,price_range,INDICATOR_DATA);
   SetIndexBuffer(1,price_major_symbol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,price_minor_symbol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,price_cross_symbol,INDICATOR_CALCULATIONS);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   
   if(prev_calculated==0)
     {
      for(int i=0;i<rates_total;i++)
        {
         double price_minor[],price_cross[];
         while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
            {
               Sleep(500);
               //Print("Copy Close on-going");
            }
         while(CopyClose(Inp_Cross_Symbol,_Period,time[i],1,price_cross)==-1)
            {
               Sleep(500);
               //Print("Copy Close on-going");
            }
         //Print(price_minor[0]," ",price_cross[0]);
         price_major_symbol[i]=close[i];
         price_minor_symbol[i]=price_minor[0];
         price_cross_symbol[i]=price_cross[0];
         price_range[i]=price_major_symbol[i]*price_minor_symbol[i]-price_cross_symbol[i];
        }
      limit=0;
     }
   else
      limit=prev_calculated-1;
      
   for(int i=limit;i<rates_total;i++)
     {
      double price_minor[],price_cross[];
      while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
         {
          Sleep(500);
          //Print("Copy Close on-going");
         }
      while(CopyClose(Inp_Cross_Symbol,_Period,time[i],1,price_cross)==-1)
         {
          Sleep(500);
            //Print("Copy Close on-going");
         }
      price_major_symbol[i]=close[i];
      price_minor_symbol[i]=price_minor[0];
      price_cross_symbol[i]=price_cross[0];
      price_range[i]=price_major_symbol[i]*price_minor_symbol[i]-price_cross_symbol[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
