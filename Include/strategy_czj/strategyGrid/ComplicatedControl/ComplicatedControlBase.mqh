//+------------------------------------------------------------------+
//|                                       ComplicatedControlBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "common_define.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CComplicatedControlBase:public CStrategy
  {
protected:
   MqlTick           latest_price[28]; // 28个品种对的最新报价
   RiskInfor         risk_state;   // 当前的风险状态

   ENUM_OPEN_STATE   open_long_state[28];  // 品种多头开仓状态
   ENUM_OPEN_STATE   open_short_state[28];  // 品种空头开仓状态
   ENUM_CLOSE_STATE  close_long_state[28];  // 品种多头平仓状态
   ENUM_CLOSE_STATE  close_short_state[28]; //品种空头平仓状态
   CArrayLong        long_pos_id[28];  // 品种多头仓位ID
   CArrayLong        short_pos_id[28]; // 品种空头仓位ID
   CArrayLong        long_pos_level[28];  // 品种多头仓位等级
   CArrayLong        short_pos_level[28]; // 品种空头仓位等级

   int               c_index[28][2];  // 存储币种序号和品种序号的对应索引关系
                                      //   仓位风险相关的衡量指标
   double            currencies_risk[8][2];  // 存储币种多空手数
   double            sym_risk[28][2]; // 存储品种多空手数
   double            sym_profits[28];  //  品种当前的盈利
   double            profits_total; // 总盈利

protected:
   void              RefreshTickPrice(){for(int i=0;i<28;i++) SymbolInfoTick(SYMBOLS_28[i],latest_price[i]);};   // 刷新tick报价
                                                                                                                 //void              RefreshPositionState(){for(int i=0;i<28;i++) pos_state[i].Refresh();};  // 刷新仓位信息
   virtual void      RefreshRiskInfor(){};   // 刷新风险信息 
   virtual void      ControlRisk(){}; // 控制风险操作
   void              PrintRiskInfor(); // 打印当前风险信息

   double            DistanceLatestPriceToLastBuyPrice(int index); // 同上次买价的下降的距离
   double            DistanceLatestPriceToLastSellPrice(int index); // 同上次卖价的上升的距离
   double            HoursLatestTimeToLastBuyTime(int index);  // 同上次买的时间差
   double            HoursLatestTimeToLastSellTime(int index); // 同上次卖的时间差 

   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose(){};      // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event){}; // 开仓判断
                                                              //void              CheckPositionOpenOnBarM1();   // M1上的开仓判断
   //void              CheckPositionOpenOnBarM5();   // M5上的开仓判断
   //void              CheckPositionOpenOnBarM30();   // M30上的开仓判断
   //void              CheckPositionOpenOnBarH1();   // H1上的开仓判断
   //void              CheckPositionOpenOnBarH4();   // H4上的开仓判断

   virtual void      CopyBufferOnBarM1(){}; // 复制M1上指标值的操作
   virtual void      CopyBufferOnBarM5(){}; // 复制M5上指标值的操作
   virtual void      CopyBufferOnBarM30(){}; // 复制M30上指标值的操作
   virtual void      CopyBufferOnBarH1(){}; // 复制H1上指标值的操作
   virtual void      CopyBufferOnBarH4(){}; // 复制H4上指标值的操作

                                            //   virtual void      NormGridOpenLongOnBarM1(int index){};   // M1--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenLongOnBarM1(int index){}; // M1--信号网格加仓操作
   //   virtual void      HedgeGridOpenLongOnBarM1(int index){};  // M1--对冲开仓和加仓操作
   //   virtual void      NormGridOpenLongOnBarM5(int index){};   // M5--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenLongOnBarM5(int index){}; // M5--信号网格加仓操作
   //   virtual void      HedgeGridOpenLongOnBarM5(int index){};  // M5--对冲开仓和加仓操作
   //   virtual void      NormGridOpenLongOnBarM30(int index){};   // M30--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenLongOnBarM30(int index){}; // M30--信号网格加仓操作
   //   virtual void      HedgeGridOpenLongOnBarM30(int index){};  // M30--对冲开仓和加仓操作
   //   virtual void      NormGridOpenLongOnBarH1(int index){};   // H1--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenLongOnBarH1(int index){}; // H1--信号网格加仓操作
   //   virtual void      HedgeGridOpenLongOnBarH1(int index){};  // H1--对冲开仓和加仓操作
   //   virtual void      NormGridOpenLongOnBarH4(int index){};   // H4--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenLongOnBarH4(int index){}; // H4--信号网格加仓操作
   //   virtual void      HedgeGridOpenLongOnBarH4(int index){};  // H4--对冲开仓和加仓操作
   //
   //   virtual void      NormGridOpenShortOnBarM1(int index){};   // M1--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenShortOnBarM1(int index){}; // M1--信号网格加仓操作
   //   virtual void      HedgeGridOpenShortOnBarM1(int index){};  // M1--对冲开仓和加仓操作
   //   virtual void      NormGridOpenShortOnBarM5(int index){};   // M5--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenShortOnBarM5(int index){}; // M5--信号网格加仓操作
   //   virtual void      HedgeGridOpenShortOnBarM5(int index){};  // M5--对冲开仓和加仓操作
   //   virtual void      NormGridOpenShortOnBarM30(int index){};   // M30--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenShortOnBarM30(int index){}; // M30--信号网格加仓操作
   //   virtual void      HedgeGridOpenShortOnBarM30(int index){};  // M30--对冲开仓和加仓操作
   //   virtual void      NormGridOpenShortOnBarH1(int index){};   // H1--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenShortOnBarH1(int index){}; // H1--信号网格加仓操作
   //   virtual void      HedgeGridOpenShortOnBarH1(int index){};  // H1--对冲开仓和加仓操作
   //   virtual void      NormGridOpenShortOnBarH4(int index){};   // H1--正常网格开仓和加仓操作
   //   virtual void      SignalGridOpenShortOnBarH4(int index){}; // H1--信号网格加仓操作
   //   virtual void      HedgeGridOpenShortOnBarH4(int index){};  // H1--对冲开仓和加仓操作

   void              ClosePositionOnOneSymbolAt(int index,string comment=""); // 将某个品种的所有仓位平掉
public:
                     CComplicatedControlBase(void);
                    ~CComplicatedControlBase(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComplicatedControlBase::CComplicatedControlBase(void)
  {
//    初始化币种序号和品种序号的对应关系
   int index;
   for(int i=0;i<7;i++)
     {
      for(int j=i+1;j<8;j++)
        {
         index=i*(15-i)/2+j-i-1;
         c_index[index][0]=i;
         c_index[index][1]=j;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToLastBuyPrice(int index)
  {
   PositionSelectByTicket(long_pos_id[index].At(long_pos_id[index].Total()-1));
   double last_price=PositionGetDouble(POSITION_PRICE_OPEN);
   return (last_price-latest_price[index].ask)/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToLastSellPrice(int index)
  {
   PositionSelectByTicket(short_pos_id[index].At(short_pos_id[index].Total()-1));
   double last_price=PositionGetDouble(POSITION_PRICE_OPEN);
   return (latest_price[index].bid-last_price)/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::HoursLatestTimeToLastBuyTime(int index)
  {
   PositionSelectByTicket(long_pos_id[index].At(long_pos_id[index].Total()-1));
   long last_time=PositionGetInteger(POSITION_TIME);
   return (long(latest_price[index].time)-last_time)/(60*60*24);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::HoursLatestTimeToLastSellTime(int index)
  {
   PositionSelectByTicket(short_pos_id[index].At(short_pos_id[index].Total()-1));
   long last_time=PositionGetInteger(POSITION_TIME);
   return (long(latest_price[index].time)-last_time)/(60*60*24);
  }
//+------------------------------------------------------------------+
void CComplicatedControlBase::OnEvent(const MarketEvent &event)
  {
// Tick 事件处理 <= tick数据更新，仓位状态更新，风险更新，平仓判断
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshRiskInfor();
      ControlRisk();
      CheckPositionClose();
     }
// BAR 事件处理 <= 开仓判断
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CheckPositionOpen(event);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::ClosePositionOnOneSymbolAt(int index,string comment="")
  {
   for(int j=0;j<long_pos_id[index].Total();j++)
     {
      Trade.PositionClose(long_pos_id[index].At(j),comment);
     }
   long_pos_id[index].Clear();
   long_pos_level[index].Clear();
   for(int j=0;j<short_pos_id[index].Total();j++)
     {
      Trade.PositionClose(short_pos_id[index].At(j),comment);
     }
   short_pos_id[index].Clear();
   short_pos_level[index].Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::PrintRiskInfor(void)
  {
   for(int i=0;i<8;i++)
     {
      Print("货币-",CURRENCIES_8[i]," long lots:",DoubleToString(currencies_risk[i][0],2)," short lots:",DoubleToString(currencies_risk[i][1],2));
     }
  }
//+------------------------------------------------------------------+
