//+------------------------------------------------------------------+
//|                                              GridBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "网格的基本操作集成"
#property description "设置通用方法--手数序列的关键参数"
#property description "设置首仓进场信号"
#property description "设置加仓信号"

#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridBaseOperate:public CStrategy
  {
protected:
   MqlTick           latest_price;  // 最新的tick报价
   CArrayLong        long_pos_id;   // 多头仓位的id数组
   CArrayLong        short_pos_id;   // 空头仓位的id数组
   CArrayInt         long_pos_level;   // 记录多头仓位的级别序列
   CArrayInt         short_pos_level;   // 记录空头仓位的级别序列
   double            last_open_long_price;   // 最后一次多头开仓价格
   double            last_open_short_price;  // 最后一次空头开仓价格
   double            cost_long_price;  // 多头成本价
   double            cost_short_price; // 空头成本价
   double            base_lots;   // 基础手数
   double            base_lots_buy;
   double            base_lots_sell;
   GridLotsCalType   lots_type;   // 计算手数的方式
   int               num_pos_1;   //  指数手数序列从0.01到1时对应的仓位
   string            close_flag; // 平仓备注
   string            open_flag;  // 开仓备注
   
public:
   PositionInfor     pos_state;   // 仓位信息
protected:
   void              CalCostPrice();   // 计算成本价格
   void              ReGetPosID();  // 重新获取多/空的仓位号
   virtual void      CheckPositionClose(){};
   virtual void      CheckPositionOpen(){};
public:
                     CGridBaseOperate(void);
                    ~CGridBaseOperate(void){};
    // 设置/获取手数序列相关参数，Pos_max仅在指定为LOS_EXP有效               
   void              SetLotsParameter(double lots_,GridLotsCalType lots_type_,int pos_max);   
   void              SetBaseBuyLots(double l){base_lots_buy=l;};
   void              SetBaseSellLots(double l){base_lots_sell=l;};
   double            GetBaseLots(){return base_lots;};
   double            GetBaseBuyLots(){return base_lots_buy;};
   double            GetBaseSellLots(){return base_lots_sell;};
   //--- 策略状态刷新                  
   void              RefreshTickPrice(){SymbolInfoTick(ExpertSymbol(),latest_price);};   // 刷新最新报价
   virtual void      RefreshPositionState();  // 刷新仓位信息 -- 刷新pos_state的状态
   virtual void      RefreshCloseComment(string comment="32610"){close_flag=comment;}; // 重置备注信息
   int               DistanceAtLastShortPositionPrice(); // 和当前空头最后一个仓位比，又上升的点数
   int               DistanceAtLastLongPositionPrice(); // 和当前多头最后一个仓位比，又下跌的点数
   // 开仓和加仓条件                    
   virtual bool      FirstLongCondition(); // 多头建首仓条件
   virtual bool      FirstShortCondition();   // 空头建首仓条件
   virtual bool      AddLongCondition();   // 多头加仓条件
   virtual bool      AddShortCondition();  // 空头加仓条件
// 仓位操作
   void              OpenLongPosition(double bl=0); //多头建仓操作
   void              OpenShortPosition(double bl=0);   // 空头建仓操作
   bool              CloseAllLongPosition(); // 多头平仓操作
   bool              CloseAllShortPosition();   // 空头平仓操作

   //--- 策略的特殊操作
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling){Trade.SetTypeFilling(filling);};// 设置执行订单的方式
   void              ReBuildPositionState(); // 重建仓位信息
   void              ReModifyTP(int tp_points);
 
// 设置操作
   void              SetCloseFlag(string flag){close_flag=flag;};
   void              SetOpenFlag(string flag){open_flag=flag;};  
// 获取信息
   int               GetLastLongLevel(){return long_pos_level.Total()==0?0:long_pos_level.At(long_pos_level.Total()-1);};   // 获取最后一个多头仓位的级别
   int               GetLastShortLevel(){return short_pos_level.Total()==0?0:short_pos_level.At(short_pos_level.Total()-1);};   //获取最后一个空头仓位的级别  
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperate::OpenLongPosition(double bl=0)
  {
   double l=bl==0?CalGridLots(GetLastLongLevel()+1,base_lots_buy,lots_type):bl;
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,open_flag))
     {
      long_pos_id.Add(Trade.ResultOrder());
      long_pos_level.Add(GetLastLongLevel()+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperate::OpenShortPosition(double bl=0)
  {
   double l=bl==0?CalGridLots(GetLastLongLevel()+1,base_lots_buy,lots_type):bl;
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,open_flag))
     {
      short_pos_id.Add(Trade.ResultOrder());
      short_pos_level.Add(GetLastShortLevel()+1);
     }
  }
//+------------------------------------------------------------------+
//|              平多头仓位                                          |
//+------------------------------------------------------------------+
bool CGridBaseOperate::CloseAllLongPosition()
  {
   bool close_all=true;
   for(int i=0;i<long_pos_id.Total();i++)
     {
      int counter=0;
      bool close_success=false;
      while(true)
        {
         close_success=Trade.PositionClose(long_pos_id.At(i),close_flag);
         if(close_success || counter>5) break;
         counter++;
         Sleep(500);
        }
      if(!close_success) close_all=false;
     }
   long_pos_id.Clear();
   long_pos_level.Clear();
   return close_all;
  }
//+------------------------------------------------------------------+
//|             平空头仓位                                           |
//+------------------------------------------------------------------+
bool CGridBaseOperate::CloseAllShortPosition()
  {
   bool close_all=true;
   for(int i=0;i<short_pos_id.Total();i++)
     {
      int counter=0;
      bool close_success=false;
      close_all=Trade.PositionClose(short_pos_id.At(i),close_flag);
      if(close_success || counter>5) break;
      counter++;
      Sleep(500);
      if(!close_success) close_all=false;
     }
   short_pos_id.Clear();
   short_pos_level.Clear();
   return close_all;
  }
//+------------------------------------------------------------------+
