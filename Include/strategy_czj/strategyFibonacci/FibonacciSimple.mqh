//+------------------------------------------------------------------+
//|                                              FibonacciSimple.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Math\Alglib\alglib.mqh>
class CFibonacciSimple:public CStrategy
  {
private:
   int               num_pattern_recognize; //模式识别需要的周期
   int               num_pattern_max;//模式允许的最大周期
   int               point_range;//模式允许的最小的趋势长度
   double            open_ratio;//入场的Fibonacci比例
   double            tp_ratio;//止盈的Fibonacci比例
   double            sl_ratio;//止损的Fibonacci比例
   double            lots;//下单手数
   double            bias_p;
   int bias_prob_num;
   int bias_period;
   double lots_factor;
   int handle_bias;

   MqlTick           latest_price;//当前的tick报价
   double            max_price,min_price;
   OpenSignal        open_signal;//模式对应的开仓信号
   double            open_price;//用于开仓的比较价格
   double            tp_price;//用于止盈的价格
   double            sl_price;//用于止损的价格
   PositionInfor     pos_state; //存储仓位情况
   CAlglib alg;
protected:
   virtual void      OnEvent(const MarketEvent &event);// 事件处理
   void              RefreshPositionStates();   //刷新当前仓位信息
public:
                     CFibonacciSimple(void);
                    ~CFibonacciSimple(void){};
                     void SetBasicParameters(int n_recognize, int n_max, int range_points, double ratio_open, double ratio_tp, double ratio_sl,double lots_base);
                     void SetBiasParameters(ENUM_TIMEFRAMES bias_tf, int period_bias,int n_cal_bias,double prob_bias, double coef_lots);
  };
CFibonacciSimple::CFibonacciSimple(void)
   {
    //num_pattern_recognize=12;
    //num_pattern_max=4;
    //point_range=500;
    //open_ratio=0.382;
    //tp_ratio=0.618;
    //sl_ratio=-1;
    //lots=0.1;
    //bias_p=0.20;
    //bias_prob_num=100;
    //lots_factor = 2;
    //handle_bias = iCustom(ExpertSymbol(),PERIOD_M15,"MyIndicators\\CZJIndicators\\IndBias",24);
   }
void CFibonacciSimple::SetBasicParameters(int n_recognize,int n_max,int range_points,double ratio_open,double ratio_tp,double ratio_sl,double lots_base)
   {
    num_pattern_recognize=n_recognize;
    num_pattern_max=n_max;
    point_range=range_points;
    open_ratio=ratio_open;
    tp_ratio=ratio_tp;
    sl_ratio=ratio_sl;
    lots=lots_base;
   }
void CFibonacciSimple::SetBiasParameters(ENUM_TIMEFRAMES bias_tf,int period_bias,int n_cal_bias,double prob_bias,double coef_lots)
   {
    bias_p=prob_bias;
    bias_prob_num=n_cal_bias;
    lots_factor = coef_lots;
    handle_bias = iCustom(ExpertSymbol(),bias_tf,"MyIndicators\\CZJIndicators\\IndBias",period_bias);
   }
void CFibonacciSimple::RefreshPositionStates(void)
   {
    pos_state.Init();
    for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) pos_state.num_buy++;
      else pos_state.num_sell++;
     }
   }
void CFibonacciSimple::OnEvent(const MarketEvent &event)
   {
    //新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      //计算最高最低价及对应的位置
      double high[],low[];
      int max_loc,min_loc;
      ArrayResize(high,num_pattern_recognize);
      ArrayResize(low,num_pattern_recognize);
      CopyHigh(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,high);
      CopyLow(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,low);
      max_loc=ArrayMaximum(high);
      min_loc=ArrayMinimum(low);
      max_price=high[max_loc];
      min_price=low[min_loc];
      //最高最低价必须超过给定价格差并且两个极值价格间的Bar数必须小于给定的模式最大长度
      if(max_price-min_price>=point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && max_price-min_price<=5*point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && MathAbs(max_loc-min_loc)<=num_pattern_max)
        {
         if(max_loc>min_loc)
           {
            open_signal=OPEN_SIGNAL_BUY;
            open_price=open_ratio*(max_price-min_price)+min_price;
            tp_price=NormalizeDouble(tp_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(sl_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
         if(max_loc<min_loc)
           {
            open_signal=OPEN_SIGNAL_SELL;
            open_price=max_price-open_ratio*(max_price-min_price);
            tp_price=NormalizeDouble(max_price-tp_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(max_price-sl_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
        }
      else open_signal=OPEN_SIGNAL_NULL;
     }
//tick事件发生时，对应的处理
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionStates();
      if(open_signal==OPEN_SIGNAL_BUY && latest_price.ask<open_price && pos_state.num_buy==0)
        {
         double adjust_lots=lots;
         double bias_value[];
         double bias_pvalue;
         CopyBuffer(handle_bias,0,0,bias_prob_num,bias_value);
         alg.SamplePercentile(bias_value,bias_p,bias_pvalue);
         if(bias_value[0]<bias_pvalue) adjust_lots = lots*lots_factor;
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY, adjust_lots,latest_price.ask,sl_price,tp_price)) return;
        }
      if(open_signal==OPEN_SIGNAL_SELL && latest_price.bid>open_price && pos_state.num_sell==0)
        {
         double adjust_lots=lots;
         double bias_value[];
         double bias_pvalue;
         CopyBuffer(handle_bias,0,0,bias_prob_num,bias_value);
         alg.SamplePercentile(bias_value,bias_p,bias_pvalue);
         if(bias_value[0]>1-bias_pvalue) adjust_lots = lots*lots_factor;
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL, adjust_lots,latest_price.bid,sl_price,tp_price)) return;
        }
     }
   }