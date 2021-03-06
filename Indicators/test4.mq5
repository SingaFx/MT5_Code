//+------------------------------------------------------------------+
//|                                                         BIAS.mq4 |
//|                                     Copyright 2016, DaiXiaoRong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, DaiXiaoRong."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_color2 Magenta
#property indicator_color3 Yellow

//--- input parameters
input int      InpShortMA=6;
input int      InpMedMA=12;
input int      InpLongMA=24;

//--- indicator buffers
double    ExtShortBiasBuffer[];
double    ExtMedBiasBuffer[];
double    ExtLongBiasBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

 //  IndicatorDigits(Digits+1);//设置指标数值保留的小数点位数

//--- drawing settings

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtShortBiasBuffer);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMedBiasBuffer);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtLongBiasBuffer);

//--- name for DataWindow and indicator subwindow label

   IndicatorShortName("BIAS("+IntegerToString(InpShortMA)+","+IntegerToString(InpMedMA)+","+IntegerToString(InpLongMA)+")");
   SetIndexLabel(0,"BIAS_short");
   SetIndexLabel(1,"BIAS_medin");
   SetIndexLabel(2,"BIAS_long");

//--- check for input parameters

   if(InpShortMA<=1 || InpMedMA<=1 || InpLongMA<=1 || InpShortMA>=InpMedMA || InpShortMA>=InpLongMA || InpMedMA>=InpLongMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;

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
   int i,limit;

//输入参数错误返回0

   if(rates_total<=InpShortMA || !ExtParameters)
      return(0);

//--- last counted bar will be recounted

   limit=rates_total-prev_calculated;//若有新bar,limit=1,无则为limit=0 
   if(prev_calculated>0)
      limit++;

//--- Calculate BIAS

   double ShortMA;
   double MedMA;
   double LongMA;

   for(i=0; i<limit; i++)
     {
      ShortMA=iMA(NULL,0,InpShortMA,0,MODE_SMA,PRICE_CLOSE,i);
      if(ShortMA>0)
         ExtShortBiasBuffer[i]=((Close[i]-ShortMA)/ShortMA)*100;//预防分母为零的情况

      MedMA=iMA(NULL,0,InpMedMA,0,MODE_SMA,PRICE_CLOSE,i);
      if(MedMA>0)
         ExtMedBiasBuffer[i]=((Close[i]-MedMA)/MedMA)*100;

      LongMA=iMA(NULL,0,InpLongMA,0,MODE_SMA,PRICE_CLOSE,i);
      if(LongMA>0)
         ExtLongBiasBuffer[i]=((Close[i]-LongMA)/LongMA)*100;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+