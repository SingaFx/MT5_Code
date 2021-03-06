//+------------------------------------------------------------------+
//|                                                      KDCrossDetector.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property description "KD交叉检测"
#property description "--KD指标参数"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2

input int InpUpLevel=80;
input int InpDownLevel=20;
input int InpKPeriod=81;
input int InpDPeriod=9;
input int InpSlow=9;
input ENUM_MA_METHOD InpMethod=MODE_EMA;
input ENUM_STO_PRICE InpPriceType=STO_LOWHIGH;

double BuyPrice[];
double SellPrice[];
double Signal[];

datetime last_time=0;
int h_stoch;
double buffer_main[];
double buffer_signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BuyPrice,INDICATOR_DATA);
   SetIndexBuffer(1,SellPrice,INDICATOR_DATA);
   SetIndexBuffer(2,Signal,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_ARROW,116);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"KD交叉检测--Buy");
   PlotIndexSetInteger(1,PLOT_ARROW,116);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"KD交叉检测--Sell");

   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
   ArraySetAsSeries(Signal,true);

   h_stoch=iStochastic(NULL,NULL,InpKPeriod,InpDPeriod,InpSlow,InpMethod,InpPriceType);
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
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   int num_bar_check=InpKPeriod+1;
   if(rates_total<num_bar_check) return 0;

   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];

   int num_handle;
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;

   CopyBuffer(h_stoch,0,0,num_handle+num_bar_check,buffer_main);
   CopyBuffer(h_stoch,1,0,num_handle+num_bar_check,buffer_signal);
   
   ArraySetAsSeries(buffer_main,true);
   ArraySetAsSeries(buffer_signal,true);

   for(int i=num_handle-1;i>=0;i--)
     {
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      Signal[i]=0;
      
      if(buffer_main[i+1]<buffer_signal[i+1]&&buffer_main[i+2]>buffer_signal[i+2]&&buffer_main[i+1]>InpUpLevel)
        {
         SellPrice[i]=open[i];
         Signal[i]=-1;
        }
      else if(buffer_main[i+1]>buffer_signal[i+1]&&buffer_main[i+2]<buffer_signal[i+2]&&buffer_main[i+1]<InpDownLevel)
        {
         BuyPrice[i]=open[i];
         Signal[i]=1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
