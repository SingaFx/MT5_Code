//+---------------------------------------------------------------------+
//|                                                WeightOscillator.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description  "Oscillator, representing the weighted smoothed sum of four indicators: RSI, MFI, WPR and DeMarker."
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------------------+
//|  Indicator drawing parameters                 |
//+-----------------------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- the following colors are used as the indicator colors
#property indicator_color1  clrDodgerBlue,clrPaleTurquoise,clrGray,clrGold,clrOrange
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1  "WeightOscillator"
//+-----------------------------------------------+
//| Parameters of displaying horizontal levels    |
//+-----------------------------------------------+
#property indicator_level1  0
#property indicator_levelcolor clrRed
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------------------+
//|  declaring constants                          |
//+-----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------------------+
//|  CXMA class description                       |
//+-----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------------+

//---- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------------------+
//|  Declaration of enumerations                  |
//+-----------------------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                   |
//+-----------------------------------------------+
//---- RSI parameters
input double RSIWeight=1.0;
input uint   RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- MFI parameters
input double MFIWeight=1.0;
input uint   MFIPeriod=14;
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;
//---- WPR parameters
input double WPRWeight=1.0;
input uint   WPRPeriod=14;
//---- DeMarker parameters
input double DeMarkerWeight=1.0;
input uint   DeMarkerPeriod=14;
//---- Enabling wave smoothing
input Smooth_Method bMA_Method=MODE_JJMA; // Smoothing method
input uint bLength=5; // Smoothing depth                    
input int bPhase=100; // Smoothing parameter,
//---- for JJMA within the range of -100 ... +100 it influences the quality of the transition process;
//---- for VIDIA it is a CMO period, for AMA it is a slow average period
input uint HighLevel=70;         // Overbought level
input uint LowLevel=30;          // Oversold levels
//+-----------------------------------------------+
//---- Declaring dynamic arrays that will be further used as the indicator buffers
double UpBuffer[],DnBuffer[],ColorBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_total_1;
//---- Declaration of a variable for a total weight coefficient
double SumWeight;
//---- Declaration of integer variables for the indicator handles
int RSI_Handle,MFI_Handle,WPR_Handle,DeMarker_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Checking the correctness of the overbought level
  if(HighLevel<50)
     {
      Print(" The value of the overbought level must not be less than 50");
      return(INIT_FAILED);
     }
//---- Checking the correctness of the oversold level
  if(LowLevel>50)
     {
      Print(" The value of the oversold level must not be greater than 50");
      return(INIT_FAILED);
     }
     
//---- Initialization of variables of data calculation starting point
   min_rates_total_1=int(MathMax(RSIPeriod,MathMax(MFIPeriod,MathMax(WPRPeriod,DeMarkerPeriod))))+1;
   min_rates_total=min_rates_total_1+GetStartBars(bMA_Method,bLength,bPhase);
   SumWeight=RSIWeight+MFIWeight+WPRWeight+DeMarkerWeight;

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("bLength",bLength);
   XMA1.XMAPhaseCheck("bPhase",bPhase,bMA_Method);

//---- Getting the handle of the iRSI indicator
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iRSI indicator");
      return(INIT_FAILED);
     }
//---- getting handle of the iMFI indicator
   MFI_Handle=iMFI(NULL,0,MFIPeriod,MFIVolumeType);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMFI indicator");
      return(INIT_FAILED);
     }
//---- getting handle of the iWPR indicator
   WPR_Handle=iWPR(NULL,0,WPRPeriod);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iWPR indicator");
      return(INIT_FAILED);
     }
//---- getting handle of the iDeMarker indicator
   DeMarker_Handle=iDeMarker(NULL,0,DeMarkerPeriod);
   if(DeMarker_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iDeMarker indicator");
      return(INIT_FAILED);
     }
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
//---- Disable display of indicator values in the upper left corner of the indicator window
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   ArraySetAsSeries(UpBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(bMA_Method);
   StringConcatenate(shortname,"WeightOscillator(",bLength,", ",Smooth1,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- the number of the indicator 3 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- the following colors are used for horizontal levels lines 
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLimeGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- Short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(MFI_Handle)<rates_total
      || BarsCalculated(WPR_Handle)<rates_total
      || BarsCalculated(DeMarker_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,maxbar;
   double RSI[],MFI[],WPR[],DeMarker[],WeightOscillator;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+1;

//---- copy newly appeared data in the arrays
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   if(CopyBuffer(MFI_Handle,0,0,to_copy,MFI)<=0) return(RESET);
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(RESET);
   if(CopyBuffer(DeMarker_Handle,0,0,to_copy,DeMarker)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(MFI,true);
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(DeMarker,true);
//----   
   maxbar=rates_total-min_rates_total_1-1;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      WeightOscillator=(RSIWeight*RSI[bar]+MFIWeight*MFI[bar]+WPRWeight*(WPR[bar]+100)+DeMarkerWeight*100*DeMarker[bar])/SumWeight;      
      UpBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,bMA_Method,bPhase,bLength,WeightOscillator,bar,true);
      DnBuffer[bar]=50.0;
      int clr=2.0;
      if(UpBuffer[bar]>HighLevel) clr=0.0;
      else if(UpBuffer[bar]>50) clr=1.0;
      else if(UpBuffer[bar]<LowLevel) clr=4.0;     
      else if(UpBuffer[bar]<50) clr=3.0;
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
