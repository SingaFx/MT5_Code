//+------------------------------------------------------------------+
//|                                                Cointegration.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Object.mqh>
#include <Math\Alglib\alglib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_COINTERGRATION_TYPE
  {
   SIMPLE_PLUS,
   SIMPLE_MULTIPLY,
   MODEL_REGRESSION,
   MODEL_GARCH,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CointegrationPair:public CObject
  {
protected:
   string            symbol_x;
   string            symbol_y;
   int               price_num;
   ENUM_TIMEFRAMES   period;
   double            price_x[];
   double            price_y[];
   double            points_x;
   double            points_y;
public:   
   double            price_x_standard[];
   double            price_y_standard[];
   double            correlation_ts[];

public:
                     CointegrationPair(void);
                    ~CointegrationPair(void){};
   void              RefreshData(void);
   void              Correlation(const double coeff_x, const double coeff_y, double &correlation[]);

  };
//---初始化
CointegrationPair::CointegrationPair(void)
  {
   symbol_x="XAUUSD";
   symbol_y="USDJPY";
   price_num=100;
   period=PERIOD_M1;
   ArrayResize(price_x,price_num);
   ArrayResize(price_y,price_num);
   ArrayResize(price_x_standard,price_num);
   ArrayResize(price_y_standard,price_num);
   points_x=SymbolInfoDouble(symbol_x,SYMBOL_POINT);
   points_y=SymbolInfoDouble(symbol_y,SYMBOL_POINT);
  }
//--- 刷新数据
CointegrationPair::RefreshData(void)
  {
   double temp_x[1];
   double temp_y[1];
   datetime dt_now=TimeCurrent();
   for(int j=0;j<price_num;j++)
     {
      CopyClose(symbol_x,period,dt_now-j*PeriodSeconds(period),1,temp_x);
      CopyClose(symbol_y,period,dt_now-j*PeriodSeconds(period),1,temp_y);
      price_x[price_num-1-j]=temp_x[0];
      price_y[price_num-1-j]=temp_y[0];
      price_x_standard[price_num-1-j]=temp_x[0]/points_x;
      price_y_standard[price_num-1-j]=temp_y[0]/points_y;
     }
  }
//+------------------------------------------------------------------+
