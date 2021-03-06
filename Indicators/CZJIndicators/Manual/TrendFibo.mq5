//+------------------------------------------------------------------+
//|                                                    TrendFibo.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property description "趋势下的黄金分割回调线"

#property indicator_buffers 5
#property indicator_plots 4
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRoyalBlue
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrBlueViolet
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrYellow
#property indicator_width3 2
#property indicator_type4 DRAW_LINE
#property indicator_color4 clrRed
#property indicator_width4 2

input int InpBarNum=55;
input double InpSupport1=0.236;
input double InpSupport2=0.382;
input double InpSupport3=0.5;
input double InpReverse=0.764;

double support1[];
double support2[];
double support3[];
double reverse[];
double trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,support1,INDICATOR_DATA);
   SetIndexBuffer(1,support2,INDICATOR_DATA);
   SetIndexBuffer(2,support3,INDICATOR_DATA);
   SetIndexBuffer(3,reverse,INDICATOR_DATA);
   SetIndexBuffer(4,trend,INDICATOR_CALCULATIONS);
   PlotIndexSetString(0,PLOT_LABEL,"Support1");
   PlotIndexSetString(1,PLOT_LABEL,"Support2");
   PlotIndexSetString(2,PLOT_LABEL,"Support3");
   PlotIndexSetString(3,PLOT_LABEL,"Trend");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Cutom indicator iteration function                              |
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
   if(rates_total<InpBarNum) return rates_total;
   
   int begin;
   if(prev_calculated<1) begin=0;
   else begin=prev_calculated-1;
   
   for(int i=begin;i<rates_total;i++)
     {
      if(i<InpBarNum) 
        {
         support1[i]=EMPTY_VALUE;
         support2[i]=EMPTY_VALUE;
         support3[i]=EMPTY_VALUE;
         reverse[i]=EMPTY_VALUE;
         trend[i]=1;
        }
      else
        {
         int imax=ArrayMaximum(high,i-InpBarNum,InpBarNum);
         int imin=ArrayMinimum(low,i-InpBarNum,InpBarNum);
         double len=(high[imax]-low[imin]);
         if(trend[i-1]==1)
           {
            if(close[i]>=high[imax]-len*InpReverse) trend[i]=1;
            else trend[i]=-1;
           }
         if(trend[i-1]==-1)
           {
            if(close[i]<=low[imin]+len*InpReverse) trend[i]=-1;
            else trend[i]=1;
           }
         
         if(trend[i]==1)
           {
            support1[i]=high[imax]-len*InpSupport1;
            support2[i]=high[imax]-len*InpSupport2;
            support3[i]=high[imax]-len*InpSupport3;
            reverse[i]=high[imax]-len*InpReverse;
           }
         else
           {
            trend[i]=-1;
            support1[i]=low[imin]+len*InpSupport1;
            support2[i]=low[imin]+len*InpSupport2;
            support3[i]=low[imin]+len*InpSupport3;
            reverse[i]=low[imin]+len*InpReverse;
           }
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
