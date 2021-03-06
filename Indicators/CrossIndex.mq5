//+------------------------------------------------------------------+
//|                                                   CrossIndex.mq5 |
//|                           Copyright © 2010,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2010, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.10"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 6
//---- использовано всего два графических построения
#property indicator_plots   2
//---- в качестве индикатора использованы цветные свечи
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrLightSeaGreen,clrDeepPink
//---- отображение метки индикатора
#property indicator_label2  "ExtOpenBuffer;ExtHighBuffer;ExtLowBuffer;ExtCloseBuffer"

//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //ExchIndWeighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price  
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string CrossIndex="EURJPY"; //валюта
//----
input color BidColor=Red;
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID;
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа в нулевом буфере
input int IndicatorDigits=3; //формат точности отображения индикатора
input bool Direct=true; //инверсия графика
//+----------------------------------------------+

bool InitResult;
int prev_calculated_=0;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//+------------------------------------------------------------------+
//| Получение минимального количества баров для тайсерии             |
//+------------------------------------------------------------------+
int Rates_Total(string symbol,int Rates_total)
  {
//----
   static datetime LastTime[1];
   int bars=Bars(symbol,PERIOD_CURRENT);
//----
   int error=GetLastError();
   ResetLastError();
   if(error==4401) return(RESET);

   int rates_total_=MathMin(Rates_total,bars);

   datetime Time[1];
   if(CopyTime(symbol,0,bars-1,1,Time)<=0) return(RESET);
   if(Time[0]!=LastTime[0])
     {
      LastTime[0]=Time[0];
      return(RESET);
     }
//----
   return(rates_total_);
  }
//+------------------------------------------------------------------+
//|  Проверка синхронизации таймсерии по времени текущего бара       |
//+------------------------------------------------------------------+
bool SynchroCheck(string symbol,datetime BarTime,int Bar)
  {
//----
   datetime TimeN[1];
//----
   if(!BarTime) return(false);

   if(CopyTime(symbol,0,Bar,1,TimeN)<=0) return(false);
   else if(TimeN[0]!=BarTime) return(false);
//----
   return(true);
  }
//+X================================================================X+   
//| PriceSeries() function                                           |
//+X================================================================X+ 
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----+
   switch(applied_price)
     {
      //----+ Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----+                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----+
//return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   InitResult=true;
//---- инициализация глобальных переменных
   if(!SymbolInfoInteger(CrossIndex,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
        {
         Print(__FUNCTION__,"(): ",CrossIndex, " - Нет такого символа!!!");
         InitResult=false;
        }
      else if(!SymbolSelect(CrossIndex,true))
        {
         Print(__FUNCTION__,"(): Не удалось добавить символ для валюты ",CrossIndex," в окно MarketWatch!!!");
         InitResult=false;
        }

     }

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtCloseBuffer,INDICATOR_DATA);

//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ExtColorsBuffer,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(0,ExtBuffer,INDICATOR_CALCULATIONS);

//---- индексация элементов в буферах как в таймсериях 
   ArraySetAsSeries(ExtBuffer,true);
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,IndicatorDigits);
   
//---- переворачиваем имя валюты только для стрингов из шести букв
   string CrossIndex_=CrossIndex;  
   if(!Direct && StringLen(CrossIndex)==6) CrossIndex_=StringSubstr(CrossIndex,3,3)+StringSubstr(CrossIndex,0,3);

//---- имя для окон данных и лэйба для субъокон
   string short_name;
   StringConcatenate(short_name,"CrossIndex ",CrossIndex_,",",StringSubstr(EnumToString(_Period),7,-1));
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

//---- параметры отрисовки линии Bid   
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,BidColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,BidStyle);
   
   EventSetTimer(1);
//----  
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void OnTimer()
  {
   //static int prev_calculated_=0;
   int rates_total=Bars(Symbol(),PERIOD_CURRENT);
   
//---- Проверка символа валюты на наличие в списке терминала
   if(!InitResult) {prev_calculated_=0; return;};

//---- объявления локальных переменных 
   int cross_rates_total,to_copy,limit,bar;
   cross_rates_total=Rates_Total(CrossIndex,rates_total);
   
   datetime time0=(datetime)SeriesInfoInteger(Symbol(),PERIOD_CURRENT,SERIES_LASTBAR_DATE);

//---- Проверка количества баров на достаточность для расчёта и проверка синхронизации таймсерий 
   if(!cross_rates_total || !SynchroCheck(CrossIndex,time0,0))
     {
      if(prev_calculated_>rates_total || prev_calculated_<=0) {prev_calculated_=0; return;};

      limit=rates_total-prev_calculated_;

      for(bar=limit-1; bar>=0; bar--)
        {
         ExtColorsBuffer[bar]=1.0;
         ExtBuffer[bar]=ExtBuffer[bar+1];

         ExtOpenBuffer [bar]=ExtCloseBuffer[bar+1];
         ExtCloseBuffer[bar]=ExtCloseBuffer[bar+1];
         ExtHighBuffer [bar]=ExtCloseBuffer[bar+1];
         ExtLowBuffer  [bar]=ExtCloseBuffer[bar+1];
        }

      return;
     }

//---- расчёт стартового номера limit для цикла пересчёта баров  и предварительная инициализация буферов с пустыми значениями
   if(prev_calculated_>rates_total || prev_calculated_<=0) // проверка на первый старт расчёта индикатора
     {
      limit=cross_rates_total-1;
      int draw_begin=rates_total-limit+1;

      //---- осуществление сдвига начала отсчёта отрисовки индикатора на draw_begin
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,draw_begin);
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,draw_begin);

      for(bar=limit; bar<rates_total; bar++)
        {
         ExtOpenBuffer[bar]=0.0;
         ExtCloseBuffer[bar]=0.0;
         ExtHighBuffer[bar]=0.0;
         ExtLowBuffer[bar]=0.0;
        }
     }
   else
     {
      limit=rates_total-prev_calculated_;
      if(limit>cross_rates_total-1) {prev_calculated_=0; return;};
     }

//---- расчёт количества копируемых данных   
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyOpen (CrossIndex,PERIOD_CURRENT,0,to_copy,ExtOpenBuffer)<=0)  {prev_calculated_=0; return;};
   if(CopyHigh (CrossIndex,PERIOD_CURRENT,0,to_copy,ExtHighBuffer)<=0)  {prev_calculated_=0; return;};
   if(CopyLow  (CrossIndex,PERIOD_CURRENT,0,to_copy,ExtLowBuffer)<=0)   {prev_calculated_=0; return;};
   if(CopyClose(CrossIndex,PERIOD_CURRENT,0,to_copy,ExtCloseBuffer)<=0) {prev_calculated_=0; return;};

//---- делаем цветовую раскраску свечей
   for(bar=limit; bar>=0; bar--)
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=0.0;
      else                                       ExtColorsBuffer[bar]=1.0;

//---- грузим в нулевой буфер ExtBuffer[] расчётное значение ценовой таймсерии
   for(bar=limit; bar>=0; bar--)
      ExtBuffer[bar]=PriceSeries(IPC,bar,ExtOpenBuffer,ExtLowBuffer,ExtHighBuffer,ExtCloseBuffer);

//---- параметры перестановки линии Bid     
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[0]);
//----  
  if(prev_calculated_==0) ChartRedraw(0);
   prev_calculated_=rates_total;
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
//----
  return(rates_total);
//----
 }
//+------------------------------------------------------------------+
