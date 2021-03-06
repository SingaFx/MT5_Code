//+------------------------------------------------------------------+
//|                                        GridOneSymbolGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "网格交易"
#property description "使用分级出场的方式进行，将最重的仓位和最差行情的仓位进行条件判断出场"
#include "GridBaseOperate.mqh"

enum LotsType
  {
   ENUM_LOTS_EXP_NUM,   // 指数级手数序列
   ENUM_LOTS_FIBONACCI, // Fibonacci手数序列
   ENUM_LOTS_LINEAR  // 线性手数序列
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridOneSymbolGradeOut:public CStrategy
  {
private:
   int               grid_add;   // 网格大小
   int               tp_per_lots;   // 每手盈利出场值
   int               tp_total;   // 总盈利出场值
   int               lots_1_pos_num;   // 设定指数手数时，仓位为1时的仓位数
   double            base_lots;  // 基本手数
   CGridBaseOperate  grid_operator;    
   double            alpha;
   double            beta;
   LotsType          lt;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshState();  // 刷新仓位信息
   void              CheckPositionClose();   // 平仓检测
   void              CheckPositionOpen(); // 开仓检测
   void              LongPositionGradeOutCheck(); // 多头分级出场判断
   void              ShortPositionGradeOutCheck(); // 空头分级出场判断
   double            CalLots(int num_pos);  // 给定级别计算手数
public:
                     CGridOneSymbolGradeOut(void){};
                    ~CGridOneSymbolGradeOut(void){};
   void              Init(double b_lots=0.01,int p_num=15, int g_add=150, int tp_p_lots=100, int tp_t=300);
   void              SetLotsType(LotsType lots_type){lt=lots_type;};
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling=ORDER_FILLING_FOK) {grid_operator.SetTypeFilling(filling);};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CGridOneSymbolGradeOut::Init(double b_lots=0.01,int p_num=15, int g_add=150, int tp_p_lots=100, int tp_t=300)
  {
   grid_operator.ExpertMagic(ExpertMagic());
   grid_operator.ExpertSymbol(ExpertSymbol());
   base_lots=b_lots;
   lots_1_pos_num=p_num;
   grid_add=g_add;
   tp_per_lots=tp_p_lots;
   beta=MathLog(100)/(lots_1_pos_num-1);
   alpha=1/MathExp(beta);
   tp_total=tp_t;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridOneSymbolGradeOut::CalLots(int num_pos)
  {
   double pos_lots=0.01;
   switch(lt)
     {
      case ENUM_LOTS_FIBONACCI:
         pos_lots=NormalizeDouble(base_lots*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos)-MathPow((1-sqrt(5))/2,num_pos))),2);
         break;
      case ENUM_LOTS_LINEAR:
         pos_lots=NormalizeDouble(base_lots*num_pos,2);
         break;
      case ENUM_LOTS_EXP_NUM:
         beta=MathLog(100)/(lots_1_pos_num-1);
         alpha=1/MathExp(beta);
         pos_lots=NormalizeDouble(base_lots*alpha*exp(beta*num_pos),2);
         break;
      default:
         break;
     }
   return pos_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbolGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshPositionState();
      grid_operator.RefreshTickPrice();
      CheckPositionClose();
      grid_operator.RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CGridOneSymbolGradeOut::CheckPositionClose(void)
  {
//    根据总仓位的盈利情况进行平仓判断
   //if(grid_operator.GetTotalPositionProfitsPerLots()>tp_per_lots*1.5)
   //  {
   //   grid_operator.CloseLongPosition();
   //   grid_operator.CloseShortPosition();
   //   return;
   //  }
//// 仓位较重的方向，进行分级出场判断
//   if(grid_operator.pos_state.lots_buy>grid_operator.pos_state.lots_sell+0.5)
//     {
//      LongPositionGradeOutCheck();
//      return;
//     }
//   else if(grid_operator.pos_state.lots_sell>grid_operator.pos_state.lots_buy+0.5)
//     {
//      ShortPositionGradeOutCheck();
//      return;
//     }
//// 获利较小的仓位，进行分级出场判断     
//   if(grid_operator.GetAllLongPositionProfitsPerLots()<grid_operator.GetAllShortPositionProfitsPerLots())
//     {
//      LongPositionGradeOutCheck();
//      return;
//     }
//   else
//     {
//      ShortPositionGradeOutCheck();
//      return;
//     }
   LongPositionGradeOutCheck();
   ShortPositionGradeOutCheck();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbolGradeOut::CheckPositionOpen(void)
  {
   if(grid_operator.pos_state.num_buy==0)
     {
      grid_operator.BuildLongPosition(base_lots*1);
     }
   else if(grid_operator.DistanceAtLastLongPositionPrice()>grid_add)
     {
      double lots_current=CalLots(grid_operator.GetLastLongLevel()+1);
      grid_operator.BuildLongPosition(lots_current);
     }
   if(grid_operator.pos_state.num_sell==0)
     {
      grid_operator.BuildShortPosition(base_lots*1);
     }
   else if(grid_operator.DistanceAtLastShortPositionPrice()>grid_add)
     {
      double lots_current=CalLots(grid_operator.GetLastShortLevel()+1);
      grid_operator.BuildShortPosition(lots_current);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbolGradeOut::LongPositionGradeOutCheck(void)
  {
   long l_pos[3];
   l_pos[0]=0;
   l_pos[1]=grid_operator.pos_state.num_buy-2;
   l_pos[2]=grid_operator.pos_state.num_buy-1;
   if(grid_operator.GetPartialLongPositionProfitsPerLots(l_pos)>tp_per_lots||grid_operator.GetPartialLongPositionProfits(l_pos)>tp_total)
     {
      grid_operator.ClosePartialLongPosition(l_pos);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbolGradeOut::ShortPositionGradeOutCheck(void)
  {
   long s_pos[3];
   s_pos[0]=0;
   s_pos[1]=grid_operator.pos_state.num_sell-2;
   s_pos[2]=grid_operator.pos_state.num_sell-1;
   if(grid_operator.GetPartialShortPositionProfitsPerLots(s_pos)>tp_per_lots||grid_operator.GetPartialShortPositionProfits(s_pos)>tp_total)
     {
      grid_operator.ClosePartialShortPosition(s_pos);
     }
  }
//+------------------------------------------------------------------+
