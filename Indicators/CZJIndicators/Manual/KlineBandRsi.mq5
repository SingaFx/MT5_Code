//+------------------------------------------------------------------+
//|                                                 KlineBandRsi.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2

input int InpBarSearch=50;
input int InpBandRange=3000;

int h_band;
int h_rsi;

double band_up_value[];
double band_down_value[];
double rsi_value[];

double BuyPrice[];
double SellPrice[];
double Signal[];

datetime last_time=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BuyPrice,INDICATOR_DATA);
   SetIndexBuffer(1,SellPrice,INDICATOR_DATA);
   SetIndexBuffer(2,Signal,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"KlineBandRsi--Buy");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"KlineBandRsi--Sell");

   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
   ArraySetAsSeries(Signal,true);

   h_band=iBands(NULL,NULL,20,0,2.0,PRICE_CLOSE);
   h_rsi=iRSI(NULL,NULL,14,PRICE_CLOSE);
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

   int num_bar_check=InpBarSearch+1;
   if(rates_total<num_bar_check) return 0;

   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];

   int num_handle;
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;

   CopyBuffer(h_band,1,0,num_handle+num_bar_check,band_up_value);
   CopyBuffer(h_band,2,0,num_handle+num_bar_check,band_down_value);
   CopyBuffer(h_rsi,0,0,num_handle+num_bar_check,rsi_value);
   ArraySetAsSeries(band_up_value,true);
   ArraySetAsSeries(band_down_value,true);
   ArraySetAsSeries(rsi_value,true);

   for(int i=num_handle-1;i>=0;i--)
     {
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      Signal[i]=0;
      double max_band=band_up_value[i];
      double min_band=band_down_value[i];
      for(int j=5;j<InpBarSearch-10;j++)
        {
         if(IsMaxLeftRight(band_up_value,i+j,10,5))
           {
            max_band=band_up_value[i+j];
            break;
           }
        }
      for(int j=5;j<InpBarSearch-10;j++)
        {
         if(IsMinLeftRight(band_down_value,i+j,10,5))
           {
            min_band=band_down_value[i+j];
            break;
           }
        }

      bool short_candle=false;
      bool long_candle=false;

      if(max_band-band_down_value[i]>InpBandRange*SymbolInfoDouble(NULL,SYMBOL_POINT) && rsi_value[i]<30) // band带上轨到下轨超过给定点数，rsi超卖，kline呈支撑形态
        {
         if(IsLongCandle(open,high,low,close,i+1))
           {
            BuyPrice[i]=open[i];
            Signal[i]=1;
           }
        }
      else if(band_up_value[i]-min_band>InpBandRange*SymbolInfoDouble(NULL,SYMBOL_POINT) && rsi_value[i]>70) // band带下轨到上轨超过给定点数，rsi超买，kline呈阻力形态
        {
         if(IsShortCandle(open,high,low,close,i+1))
           {
            SellPrice[i]=open[i];
            Signal[i]=-1;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                        判断给定位置是否是极大值点                |
//+------------------------------------------------------------------+
bool IsMaxLeftRight(double &buffer[],int index,int left_num,int right_num)
  {
   int index_left_max=ArrayMaximum(buffer,index+1,left_num);
   int index_right_max=ArrayMaximum(buffer,index-right_num,right_num);
   if(buffer[index]>buffer[index_left_max]&&buffer[index]>buffer[index_right_max]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                           判断给定位置是否是极小值点             |
//+------------------------------------------------------------------+
bool IsMinLeftRight(double &buffer[],int index,int left_num,int right_num)
  {
   int index_left_min=ArrayMinimum(buffer,index+1,left_num);
   int index_right_min=ArrayMinimum(buffer,index-right_num,right_num);
   if(buffer[index]<buffer[index_left_min]&&buffer[index]<buffer[index_right_min]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsShortCandle(const double &o_price[],const double &h_price[],const double &l_price[],const double &c_price[],int index)
  {
   for(int i=index;i<index+3;i++)
     {
      if(h_price[i]-l_price[i]>MathAbs(o_price[i]-c_price[i])*3) return true; // 出现十字星

     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLongCandle(const double &o_price[],const double &h_price[],const double &l_price[],const double &c_price[],int index)
  {
   for(int i=index;i<index+3;i++)
     {
      if(h_price[i]-l_price[i]>MathAbs(o_price[i]-c_price[i])*3) return true; // 出现十字星

     }

   return false;
  }
//+------------------------------------------------------------------+
