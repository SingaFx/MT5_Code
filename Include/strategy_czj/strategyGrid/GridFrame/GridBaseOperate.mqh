//+------------------------------------------------------------------+
//|                                              GridBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "网格的基本操作集成"
#property description "设置通用方法--手数序列的关键参数"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>

//+------------------------------------------------------------------+
//|               网格止盈出场的方式                                 |
//+------------------------------------------------------------------+
enum GridWinType
  {
   ENUM_GRID_WIN_LAST,  // 最后开仓价设置止盈位
   ENUM_GRID_WIN_COST   //  成本价设置止盈位
  };
//+------------------------------------------------------------------+
//|           网格策略基本操作集成                                   |
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
public:
   PositionInfor     pos_state;   // 仓位信息
protected:
   void              CalCostPrice();   // 计算成本价格
   void              ReGetPosID();  // 重新获取多/空的仓位号
   void              ReGetPosLevel();  // 重新获取仓位等级列表
public:
                     CGridBaseOperate(void);
                    ~CGridBaseOperate(void){};
   void              SetLotsParameter(double lots_,GridLotsCalType lots_type_,int pos_max);   // 设置手数序列相关参数，Pos_max仅在指定为LOS_EXP有效
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
   //--- 策略平仓操作   
   bool              CloseAllLongPosition(); // 平多头操作
   bool              CloseAllShortPosition();   // 平空头操作

   double            CalLotsDefault(int num_pos,double base_l); // 计算第num_pos个仓位对应的手数
   int               CalLevel(double li,double base_l);  // 根据手数计算仓位等级
   //--- 策略的特殊操作
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling){Trade.SetTypeFilling(filling);};// 设置执行订单的方式
   void              ReBuildPositionState(); // 重建仓位信息
   void              ReModifyTP(int tp_points);
   virtual void      CheckPositionClose(){};
   virtual void      CheckPositionOpen(){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridBaseOperate::CGridBaseOperate(void)
  {
   long_pos_id.Clear();
   short_pos_id.Clear();
   long_pos_level.Clear();
   short_pos_level.Clear();
   last_open_long_price=DBL_MAX;
   last_open_short_price=DBL_MIN;
   SetLotsParameter(0.01,ENUM_GRID_LOTS_EXP,15);
   close_flag="32610";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperate::SetLotsParameter(double lots_=0.010000,GridLotsCalType lots_type_=1,int pos_max=15)
  {
   base_lots=lots_;
   base_lots_buy=base_lots;
   base_lots_sell=base_lots;
   lots_type=lots_type_;
   num_pos_1=pos_max;
  }
//+------------------------------------------------------------------+
//|                  刷新仓位信息                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
//|  重建仓位信息:刷新报价，重新获取多空pos_id，重新计算pos_state    |
//+------------------------------------------------------------------+
void CGridBaseOperate::ReBuildPositionState(void)
  {
   Print("重建仓位信息:刷新报价，重新获取多空pos_id，重新计算pos_state;");
   RefreshTickPrice();  // 刷新tick报价
   ReGetPosID();  // 重新获取多空的仓位id
   ReGetPosLevel();  // 重新获取仓位等级
   RefreshPositionState(); // 重新计算pos_state的状态
   last_open_long_price=DBL_MAX;
   last_open_short_price=DBL_MIN;

   if(long_pos_id.Total()>0)
     {
      PositionSelectByTicket(long_pos_id.At(long_pos_id.Total()-1));
      last_open_long_price=PositionGetDouble(POSITION_PRICE_OPEN);
     }
   Print("多头仓位数:",long_pos_id.Total()," 最后long_open_price:",DoubleToString(last_open_long_price,(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS)));

   if(short_pos_id.Total()>0)
     {
      PositionSelectByTicket(short_pos_id.At(short_pos_id.Total()-1));
      last_open_short_price=PositionGetDouble(POSITION_PRICE_OPEN);
     }
   Print("空头仓位数:",short_pos_id.Total()," 最后short_open_price:",DoubleToString(last_open_short_price,(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperate::ReModifyTP(int tp_points)
  {
   Print("TP CHECK:");
   double tp_long_price=last_open_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double tp_short_price=last_open_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   for(int i=0;i<long_pos_id.Total();i++)
     {
      int counter=0;
      bool modify_success=false;
      PositionSelectByTicket(long_pos_id.At(i));
      if(PositionGetDouble(POSITION_TP)==tp_long_price) continue;

      while(counter<50 && !modify_success)
        {
         modify_success=Trade.PositionModify(long_pos_id.At(i),0,tp_long_price);
         counter++;
         Sleep(500);
        }
      Print("modify TP Result:",modify_success," counter num:",counter," TP_LONG_PRICE:",tp_long_price);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      int counter=0;
      bool modify_success=false;
      PositionSelectByTicket(short_pos_id.At(i));
      if(PositionGetDouble(POSITION_TP)==tp_short_price) continue;
      while(counter<50 && !modify_success)
        {
         modify_success=Trade.PositionModify(short_pos_id.At(i),0,tp_short_price);
         counter++;
         Sleep(500);
        }
      Print("modify TP Result:",modify_success," counter num:",counter," TP_SHORT_PRICE:",tp_short_price);
     }
  }
//+------------------------------------------------------------------+
//|              平多头仓位                                          |
//+------------------------------------------------------------------+
bool CGridBaseOperate::CloseAllLongPosition(void)
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
bool CGridBaseOperate::CloseAllShortPosition(void)
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
//|            根据不同的方式计算对应手数                            |
//+------------------------------------------------------------------+
double CGridBaseOperate::CalLotsDefault(int num_pos,double base_l)
  {
   double pos_lots=base_l;
   double alpha,beta;
   switch(lots_type)
     {
      case ENUM_GRID_LOTS_EXP :
         pos_lots=NormalizeDouble(base_l*0.7*exp(0.4*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP15:
         pos_lots=NormalizeDouble(base_l*0.7197*exp(0.3289*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP20:
         pos_lots=NormalizeDouble(base_l*0.7848*exp(0.2424*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI:
         pos_lots=NormalizeDouble(base_l*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos)-MathPow((1-sqrt(5))/2,num_pos))),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI_1:
         pos_lots=NormalizeDouble(base_l*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos+1)-MathPow((1-sqrt(5))/2,num_pos+1))),2);
         break;
      case ENUM_GRID_LOTS_GEMINATION:
         pos_lots=NormalizeDouble(base_l*MathPow(2,num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP_NUM:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=NormalizeDouble(base_l*alpha*exp(beta*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FBS:
         pos_lots=NormalizeDouble(base_l*0.76*exp(0.2628*num_pos),2);
         break;
      case ENUM_GRID_LOTS_LINEAR:
         pos_lots=NormalizeDouble(base_l*num_pos,2);
         break;
      case ENUM_GRID_LOTS_CONST:
         pos_lots=NormalizeDouble(base_l,2);
         break;
      case ENUM_GRID_LOTS_LINEAR_STEP_N:
         pos_lots=NormalizeDouble(0.01*num_pos_1*num_pos+base_l,2);
         break; 
      case ENUM_GRID_LOTS_EXP_FILTER_5:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=num_pos<=5?0.01:NormalizeDouble(base_l*alpha*exp(beta*(num_pos-5)),2);;
         break;
      case ENUM_GRID_LOTS_EXP_FILTER_10:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=num_pos<=10?0.01:NormalizeDouble(base_l*alpha*exp(beta*(num_pos-10)),2);
         break;    
      default:
         break;
     }
   return pos_lots;
  }
int CGridBaseOperate::CalLevel(double li,double base_l)
   {
   int level=0;
   double alpha,beta;
   switch(lots_type)
     {
      case ENUM_GRID_LOTS_EXP:
         level=(int)log(li/base_l/0.7)/0.4;
         break;
      case ENUM_GRID_LOTS_EXP15:
         level=(int)log(li/base_l/0.7197)/0.3289;
         break;
      case ENUM_GRID_LOTS_EXP20:
         level=(int)log(li/base_l/0.7848)/0.2424;
         break;
      case ENUM_GRID_LOTS_FIBONACCI:
         for(int i=1;i<100;i++)
           {
            if((int)li/base_l==1)
               {
                level=1;
                break;
               }
            if(1/sqrt(5)*(MathPow((1+sqrt(5))/2,i)-MathPow((1-sqrt(5))/2,i))>=(int)li/base_l)
               {
                level=i;
                break;
               }
           }
         break;
      case ENUM_GRID_LOTS_FIBONACCI_1:
         for(int i=1;i<100;i++)
           {
            if((int)li/base_l==1)
               {
                level=1;
                break;
               }            
            if(1/sqrt(5)*(MathPow((1+sqrt(5))/2,i)-MathPow((1-sqrt(5))/2,i))>=(int)li/base_l)
               {
                level=i-1;
                break;
               }
           }
         break;
      case ENUM_GRID_LOTS_GEMINATION:
         level=(int)log(li/base_l)/log(2);
         break;
      case ENUM_GRID_LOTS_EXP_NUM:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         level=(int)(log(li/base_l/alpha)/beta);
         break;
      case ENUM_GRID_LOTS_FBS:
         level=(int)log(li/base_l/0.76)/0.2628;
         break;
      case ENUM_GRID_LOTS_LINEAR:
         level=(int)li/base_l;
         break;
      case ENUM_GRID_LOTS_CONST:
         level=1;
         break;
      case ENUM_GRID_LOTS_LINEAR_STEP_N:
         level=(int)((li-base_l)/0.01/num_pos_1);
         break; 
      case ENUM_GRID_LOTS_EXP_FILTER_5:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         level=(int)(li==0.01?1:log(li/base_l/alpha)/beta+5);
         break;
      case ENUM_GRID_LOTS_EXP_FILTER_10:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         level=(int)(li==0.01?1:log(li/base_l/alpha)/beta+10);
         break;    
      default:
         break;
     }
   return level;    
   }  
//+------------------------------------------------------------------+
//|                  计算成本价格                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::CalCostPrice(void)
  {
   double sum_long_lots=0;
   double sum_short_lots=0;
   double sum_long_price=0;
   double sum_short_price=0;
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      sum_long_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_long_price+=PositionGetDouble(POSITION_VOLUME)*PositionGetDouble(POSITION_PRICE_OPEN);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      sum_short_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_short_price+=PositionGetDouble(POSITION_VOLUME)*PositionGetDouble(POSITION_PRICE_OPEN);
     }
   cost_long_price=sum_long_lots==0?0:sum_long_price/sum_long_lots;
   cost_short_price=sum_short_lots==0?0:sum_short_price/sum_short_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperate::ReGetPosID(void)
  {
   long_pos_id.Clear();
   short_pos_id.Clear();
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)!=ExpertSymbol() || PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) long_pos_id.Add(ticket);
      else short_pos_id.Add(ticket);
     }
  }
void CGridBaseOperate::ReGetPosLevel(void)
   {
    long_pos_level.Clear();
    short_pos_level.Clear();
    if(long_pos_id.Total()>0)
      {
       PositionSelectByTicket(long_pos_id.At(0));
       double l1=PositionGetDouble(POSITION_VOLUME);
       
      }
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridBaseOperate::DistanceAtLastLongPositionPrice(void)
  {
   PositionSelectByTicket(long_pos_id.At(long_pos_id.Total()-1));
   return (int)((PositionGetDouble(POSITION_PRICE_OPEN)-latest_price.ask)*MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridBaseOperate::DistanceAtLastShortPositionPrice(void)
  {
   PositionSelectByTicket(short_pos_id.At(short_pos_id.Total()-1));
   return (int)((latest_price.bid-PositionGetDouble(POSITION_PRICE_OPEN))*MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
