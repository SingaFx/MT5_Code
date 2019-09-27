//+------------------------------------------------------------------+
//|                                                CurrencyIndex.mq5 |
//|                           Copyright © 2010,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Nikolay Kositsin"
//---- link to the author's website
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- five buffers are used for the indicator calculation and drawing
#property indicator_buffers 6
//---- only two plots are used
#property indicator_plots   2
//---- color candlesticks are used as an indicator
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  Lime, Magenta
//---- displaying the indicator label
#property indicator_label2  "Open; High; Low; Close"

//+-----------------------------------+
//|  declaration of constants              |
//+-----------------------------------+
#define RESET 0
#define SYMBOLSTOTAL 12
//+-----------------------------------+
//|  declaration of enumerations          |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
  };
//+----------------------------------------------+
//| Indicator input parameters                 |
//+----------------------------------------------+
input string CurrencyIndex="USD"; //index currency
//----
input string ExchangeIndex0="EUR"; //exchange currency 0
input string ExchangeIndex1="GBP"; //exchange currency 1
input string ExchangeIndex2="AUD"; //exchange currency 2
input string ExchangeIndex3="CAD"; //exchange currency 3
input string ExchangeIndex4="CHF"; //exchange currency 4
input string ExchangeIndex5="JPY"; //exchange currency 5
input string ExchangeIndex6=""; //exchange currency 6
input string ExchangeIndex7=""; //exchange currency 7
input string ExchangeIndex8=""; //exchange currency 8
input string ExchangeIndex9=""; //exchange currency 9
input string ExchangeIndex10=""; //exchange currency 10
input string ExchangeIndex11=""; //exchange currency 11
//----
input color BidColor=Red;
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID;
input Applied_price_ IPC=PRICE_CLOSE;//price constant in a zero buffer
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//----
double Pow;
bool Init;
int Sign[SYMBOLSTOTAL];
string Symbol_[SYMBOLSTOTAL];
//+------------------------------------------------------------------+
//| Getting the minimum number of bars for all time series        |
//+------------------------------------------------------------------+
int Rates_Total(string &Symbols[])
  {
//----
   int Bars_[SYMBOLSTOTAL];
   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      if(Sign[count]!=0) Bars_[count]=Bars(Symbols[count],PERIOD_CURRENT);
      else Bars_[count]=999999999;
     }
//----
   int error=GetLastError();
   ResetLastError();
   if(error==4401) return(-1);
//----
   return(Bars_[ArrayMinimum(Bars_,0,WHOLE_ARRAY)]);
  }
//+------------------------------------------------------------------+
//|  Checking synchronization of time series                                |
//+------------------------------------------------------------------+
bool SynchroCheck(string &Symbols[])
  {
//----
   datetime Time0[1],TimeN[1];
//----
   Time0[0]=0;

   for(int count=0; count<SYMBOLSTOTAL; count++)
      if(Sign[count]!=0 && CopyTime(Symbols[count],0,0,1,Time0)>0) break;

   if(Time0[0]==0) return(false);

   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      if(Sign[count]!=0) if(CopyTime(Symbols[count],0,0,1,TimeN)<=0) return(false);
      else if(TimeN[0]!=Time0[0]) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables Symbol_[] and Sign[]
   string symb,symbol[SYMBOLSTOTAL];

   symbol[0] = ExchangeIndex0;
   symbol[1] = ExchangeIndex1;
   symbol[2] = ExchangeIndex2;
   symbol[3] = ExchangeIndex3;
   symbol[4] = ExchangeIndex4;
   symbol[5] = ExchangeIndex5;
   symbol[6] = ExchangeIndex6;
   symbol[7] = ExchangeIndex7;
   symbol[8] = ExchangeIndex8;
   symbol[9] = ExchangeIndex9;
   symbol[10] = ExchangeIndex10;
   symbol[11] = ExchangeIndex11;

   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      if(symbol[count]=="")
        {
         Symbol_[count]="";
         Sign[count]=0;
         continue;
        }
      symb=CurrencyIndex+symbol[count];
      if(SymbolInfoInteger(symb,SYMBOL_SELECT))
        {
         Symbol_[count]=symb;
         Sign[count]=+1;
        }
      else
        {
         if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
           {
            symb=symbol[count]+CurrencyIndex;
            ResetLastError();

            if(!SymbolInfoInteger(symb,SYMBOL_SELECT))
              {
               if(GetLastError()!=ERR_MARKET_UNKNOWN_SYMBOL)
                 {
                  ResetLastError();
                  if(SymbolSelect(symb,true))
                    {
                     Symbol_[count]=symb;
                     Sign[count]=-1;
                    }
                  else
                    {
                     Symbol_[count]="";
                     Sign[count]=0;
                     Print(__FUNCTION__,"(): Failed to add the symbol for the currency ",symbol[count]," to the MarketWatch window!!!");
                     continue;
                    }
                 }
               else
                 {
                  Symbol_[count]="";
                  Sign[count]=0;
                  Print(__FUNCTION__,"(): Failed to find the symbol for the currency ",symbol[count],"!!!");
                  continue;
                 }
              }
            else
              {
               if(SymbolSelect(symb,true))
                 {
                  Symbol_[count]=symb;
                  Sign[count]=-1;
                 }
               else
                 {
                  Symbol_[count]="";
                  Sign[count]=0;
                  Print(__FUNCTION__,"(): Failed to add the symbol for the currency ",symbol[count]," to the MarketWatch window!!!");
                  continue;
                 }

              }

           }
         else
         if(SymbolSelect(symb,true))
           {
            Symbol_[count]=symb;
            Sign[count]=+1;
           }
         else
           {
            Symbol_[count]="";
            Sign[count]=0;
            Print(__FUNCTION__,"(): Failed to find or add the symbol for the currency ",symbol[count]," to the MarketWatch window!!!");
            continue;
           }
        }

     }

//---- initialization of the global variable Pow for storing the powering exponent
   int sum=0;
   for(int count=0; count<SYMBOLSTOTAL; count++) if(Sign[count]) sum++;
   Pow=1.0/sum;

//---- initialization of the global variable Init - flag of successful completion of the initialization of variables
   Init=false;
   for(int count=0; count<SYMBOLSTOTAL; count++) if(Symbol_[count]==Symbol()) Init=true;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtCloseBuffer,INDICATOR_DATA);

//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(5,ExtColorsBuffer,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(0,ExtBuffer,INDICATOR_CALCULATIONS);

//---- indexing buffer elements as time series 
   ArraySetAsSeries(ExtBuffer,true);
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);

//---- Setting the indicator display accuracy format
   IndicatorSetInteger(INDICATOR_DIGITS,6);

//---- data window name and subwindow label 
   string short_name="CurrencyIndex "+CurrencyIndex;
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

//---- Bid line drawing parameters   
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,BidColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,BidStyle);
//----  
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
//---- Checking for the sufficiency of the number of bars for the calculation and the presence of the chart symbol in the (Symbol_[] array
   int Bars_=Rates_Total(Symbol_);
   if(Bars_<1 || !Init) return(RESET);

//---- Checking synchronization of time series
   if(!SynchroCheck(Symbol_)) return(prev_calculated);

//---- declaring local variables 
   int to_copy,bar;
   MqlRates rates[];

//---- indexing array elements as time series  
   ArraySetAsSeries(rates,true);

//---- calculation of the amount of data to be copied and preliminary initialization of buffers
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      to_copy=Bars_;

      int draw_begin=rates_total-to_copy;
      //---- shifting the starting drawing point of the indicator by draw_begin
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,draw_begin);

      for(bar=to_copy; bar<rates_total; bar++)
        {
         ExtOpenBuffer[bar]=0.0;
         ExtCloseBuffer[bar]=0.0;
         ExtHighBuffer[bar]=0.0;
         ExtLowBuffer[bar]=0.0;
        }
     }
   else
     {
      to_copy=rates_total-prev_calculated+1;
      if(to_copy>Bars_) return(RESET);
     }

   for(bar=0; bar<to_copy; bar++)
     {
      ExtOpenBuffer[bar]=1.0;
      ExtCloseBuffer[bar]=1.0;
      ExtHighBuffer[bar]=1.0;
      ExtLowBuffer[bar]=1.0;
     }

//---- copying new data to the array and making preliminary calculation of candlesticks
   for(int count=0; count<SYMBOLSTOTAL; count++)
     {
      if(Sign[count]==0) continue;
      if(CopyRates(Symbol_[count],PERIOD_CURRENT,0,to_copy,rates)<=0) return(RESET);

      if(Sign[count]>0)
         for(bar=0; bar<to_copy; bar++)
           {
            ExtOpenBuffer[bar]*=rates[bar].open;
            ExtCloseBuffer[bar]*=rates[bar].close;
            ExtHighBuffer[bar]*=rates[bar].high;
            ExtLowBuffer[bar]*=rates[bar].low;
           }

      if(Sign[count]<0)
         for(bar=0; bar<to_copy; bar++)
           {
            ExtOpenBuffer[bar]/=rates[bar].open;
            ExtCloseBuffer[bar]/=rates[bar].close;
            ExtHighBuffer[bar]/=rates[bar].low;
            ExtLowBuffer[bar]/=rates[bar].high;
           }
     }

//---- final calculation of candlesticks
   for(bar=0; bar<to_copy; bar++)
     {
      ExtOpenBuffer[bar]=MathPow(ExtOpenBuffer[bar],Pow);
      ExtCloseBuffer[bar]=MathPow(ExtCloseBuffer[bar],Pow);
      ExtHighBuffer[bar]=MathPow(ExtHighBuffer[bar],Pow);
      ExtLowBuffer[bar]=MathPow(ExtLowBuffer[bar],Pow);
     }

   for(bar=0; bar<to_copy; bar++)
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=0.0;
   else                                       ExtColorsBuffer[bar]=1.0;

   for(bar=0; bar<to_copy; bar++)
      switch(IPC)
        {
         case  PRICE_CLOSE_: ExtBuffer[bar]=ExtCloseBuffer[bar]; break;
         case  PRICE_OPEN_:  ExtBuffer[bar]=ExtOpenBuffer [bar]; break;
         case  PRICE_HIGH_:  ExtBuffer[bar]=ExtHighBuffer [bar]; break;
         case  PRICE_LOW_:   ExtBuffer[bar]=ExtLowBuffer  [bar]; break;
        }

//---- Bid line shift parameters     
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[0]);

//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
