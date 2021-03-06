//+------------------------------------------------------------------+ 
//|                                              ColorZerolagRVI.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- Copyright
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the author's website
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 4 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- width of the indicator line is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1 "FastTrendLine"
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color2 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- width of the indicator line is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 "SlowTrendLine"
//+-----------------------------------+
//| Filling drawing parameters        |
//+-----------------------------------+
//---- drawing indicator as a filling between two lines
#property indicator_type3   DRAW_FILLING
//---- lime and red colors are used as the indicator filling colors
#property indicator_color3  clrSpringGreen,clrRed
//---- displaying the indicator label
#property indicator_label3 "ZerolagRVI"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint   smoothing=15;
//----
input double Factor1=0.05;
input int    RVI_period1=8;
//----
input double Factor2=0.10;
input int    RVI_period2=21;
//----
input double Factor3=0.16;
input int    RVI_period3=34;
//----
input double Factor4=0.26;
input int    RVI_period4=55;
//----
input double Factor5=0.43;
input int    RVI_period5=89;
//+-----------------------------------+
//---- declaration of integer variables for the start of data calculation
int StartBar;
//---- declaration of floating point variables
double smoothConst;
Indicator buffers
double FastBuffer[];
double SlowBuffer[];
double FastBuffer_[];
double SlowBuffer_[];
//----declaration of variables for storing the indicators handles
int RVI1_Handle,RVI2_Handle,RVI3_Handle,RVI4_Handle,RVI5_Handle;
//+------------------------------------------------------------------+    
//| ZerolagRVI indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of constants
   smoothConst=(smoothing-1.0)/smoothing;
//----
   int PeriodBuffer[5];
//---- Calculation of the starting bar
   PeriodBuffer[0] = RVI_period1;
   PeriodBuffer[1] = RVI_period2;
   PeriodBuffer[2] = RVI_period3;
   PeriodBuffer[3] = RVI_period4;
   PeriodBuffer[4] = RVI_period5;
//----
   StartBar=PeriodBuffer[ArrayMaximum(PeriodBuffer,0,WHOLE_ARRAY)]+2;
//---- getting handle of the iRVI1 indicator
   RVI1_Handle=iRVI(NULL,0,RVI_period1);
   if(RVI1_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRVI1 indicator");
//---- getting handle of the iRVI2 indicator
   RVI2_Handle=iRVI(NULL,0,RVI_period2);
   if(RVI2_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRVI2 indicator");
//---- getting handle of the iRVI3 indicator
   RVI3_Handle=iRVI(NULL,0,RVI_period3);
   if(RVI3_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRVI3 indicator");
//---- getting handle of the iRVI4 indicator
   RVI4_Handle=iRVI(NULL,0,RVI_period4);
   if(RVI_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRVI4 indicator");
//---- getting handle of the iRVI5 indicator
   RVI5_Handle=iRVI(NULL,0,RVI_period5);
   if(RVI5_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRVI5 indicator");
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,FastBuffer,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"FastTrendLine");
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(FastBuffer,true);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SlowBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBar);
//--- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"SlowTrendLine");
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SlowBuffer,true);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,FastBuffer_,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(FastBuffer_,true);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,SlowBuffer_,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SlowBuffer_,true);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBar);
//--- create label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"FastTrendLine");
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of variable for indicator short name
   string shortname="ZerolagRVI";
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| ZerolagRVI iteration function                                    | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(RVI1_Handle)<rates_total
      || BarsCalculated(RVI2_Handle)<rates_total
      || BarsCalculated(RVI3_Handle)<rates_total
      || BarsCalculated(RVI4_Handle)<rates_total
      || BarsCalculated(RVI5_Handle)<rates_total
      || rates_total<StartBar)
      return(0);
//---- declaration of floating point variables  
   double Osc1,Osc2,Osc3,Osc4,Osc5,FastTrend,SlowTrend;
   double RVI1[],RVI2[],RVI3[],RVI4[],RVI5[];
//---- declaration of integer variables
   int limit,to_copy,bar;
//---- calculation of the limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBar-2; // starting index for the calculation of all bars
      to_copy=limit+2;
     }
   else // starting number for calculation of new bars
     {
      limit=rates_total-prev_calculated;  // starting index for calculation of new bars
      to_copy=limit+1;
     }
//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(RVI1,true);
   ArraySetAsSeries(RVI2,true);
   ArraySetAsSeries(RVI3,true);
   ArraySetAsSeries(RVI4,true);
   ArraySetAsSeries(RVI5,true);
//---- copy newly appeared data in the arrays
   if(CopyBuffer(RVI1_Handle,0,0,to_copy,RVI1)<=0) return(0);
   if(CopyBuffer(RVI2_Handle,0,0,to_copy,RVI2)<=0) return(0);
   if(CopyBuffer(RVI3_Handle,0,0,to_copy,RVI3)<=0) return(0);
   if(CopyBuffer(RVI4_Handle,0,0,to_copy,RVI4)<=0) return(0);
   if(CopyBuffer(RVI5_Handle,0,0,to_copy,RVI5)<=0) return(0);
//---- calculations of the necessary amount of data to be copied
//---- the limit starting index for loop of bars recalculation
//---- and the starting initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      bar=limit+1;
      Osc1 = Factor1 * RVI1[bar];
      Osc2 = Factor2 * RVI2[bar];
      Osc3 = Factor2 * RVI3[bar];
      Osc4 = Factor4 * RVI4[bar];
      Osc5 = Factor5 * RVI5[bar];
      //---
      FastTrend=Osc1+Osc2+Osc3+Osc4+Osc5;
      FastBuffer[bar]=FastBuffer_[bar]=FastTrend;
      SlowBuffer[bar]=SlowBuffer_[bar]=FastTrend/smoothing;
     }
//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Osc1 = Factor1 * RVI1[bar];
      Osc2 = Factor2 * RVI2[bar];
      Osc3 = Factor2 * RVI3[bar];
      Osc4 = Factor4 * RVI4[bar];
      Osc5 = Factor5 * RVI5[bar];
      //---
      FastTrend = Osc1 + Osc2 + Osc3 + Osc4 + Osc5;
      SlowTrend = FastTrend / smoothing + SlowBuffer[bar + 1] * smoothConst;
      //---
      SlowBuffer[bar]=SlowTrend;
      FastBuffer[bar]=FastTrend;

      SlowBuffer_[bar]=SlowTrend;
      FastBuffer_[bar]=FastTrend;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
