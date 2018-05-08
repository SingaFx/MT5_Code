//+------------------------------------------------------------------+
//|                                                CandlePattern.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
class CCandlePatternBase
  {
protected:
   string symbol;
   ENUM_TIMEFRAMES period;
   int num_rates;
   
public:
                     CCandlePatternBase(void);
                    ~CCandlePatternBase(void);
                       
  };
CCandlePatternBase::CCandlePatternBase(void)
   {
    symbol="EURUSD";
    period=PERIOD_H1;
    num_rates=72;
   }
   
class CCandlePatternWtopMbottom:public CCandlePatternBase
  {
private:
   double m_price[4];
   double w_price[4];
   MqlRates rates[];
   double high[];
   double low[];
   bool is_w_bottom;
   bool is_m_top;
   //double v3;
public:
                     CCandlePatternWtopMbottom(void);
                    ~CCandlePatternWtopMbottom(void);
                    void RefreshRates(void);
                    bool IsWtop(void){return is_w_bottom;};
                    bool IsMbottom(void){return is_m_top;};
  };
CCandlePatternWtopMbottom::CCandlePatternWtopMbottom(void)
   {
    symbol="EURUSD";
    period=PERIOD_H1;
    num_rates=72;
    //v[0]
   }
void CCandlePatternWtopMbottom::RefreshRates(void)
   {
    is_m_top=false;
    is_w_bottom=false;
    CopyRates(symbol,period,0,num_rates,rates);
    CopyHigh(symbol,period,0,num_rates,high);
    CopyLow(symbol,period,0,num_rates,low);
    int iloc_M_max1,iloc_M_max2,iloc_M_min1,iloc_M_min2;
    int iloc_W_max1,iloc_W_max2,iloc_W_min1,iloc_W_min2;
    iloc_M_max1=ArrayMaximum(high);
    iloc_M_min1=ArrayMinimum(low,0,iloc_M_max1);
    
    iloc_M_min2=ArrayMinimum(low,iloc_M_max1,num_rates-iloc_M_max1);
    iloc_M_max2=ArrayMaximum(high,iloc_M_min2,num_rates-iloc_M_min2);
    
    m[0]=low[iloc_M_min1];
    m[1]=high[iloc_M_max1];
    m[2]=low[iloc_M_min2];
    m[3]=high[iloc_M_max2];
    
   }