//+------------------------------------------------------------------+
//|                                                   GridDouble.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"

class CGridDouble:public CStrategy
  {
private:
   int trend_points_major;
   int add_points_major;
   int trend_points_minor;
   int add_points_minor;
   int tp_major;
   int tp_minor;
   MqlDateTime       dt;
protected:
   CGridBaseOperate  major_grid;
   CGridBaseOperate  minor_grid;
public:
                     CGridDouble(void){};
                    ~CGridDouble(void){};
                    void Init();
                    void Init(int major_trend, int major_add, int minor_trend, int minor_add);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   int     CalTP(int trend_p, int add_p, int pos_add=0);
   void    MajorGridOperate();
   void    MinorGridOperate();
  };
  
void CGridDouble::Init(void)
   {
    trend_points_major=5000;
    trend_points_minor=2000;
    add_points_major=60;
    add_points_minor=300;
    tp_major=CalTP(trend_points_major,add_points_major,0);
    tp_minor=CalTP(trend_points_minor,add_points_minor,15-int(trend_points_minor/add_points_minor));
    major_grid.Init(0.01,ENUM_GRID_LOTS_EXP_NUM,int(trend_points_major/add_points_major));
    minor_grid.Init(0.01,ENUM_GRID_LOTS_EXP_NUM,int(trend_points_minor/add_points_minor));
    major_grid.ExpertMagic(ExpertMagic()+0);
    minor_grid.ExpertMagic(ExpertMagic()+1);
    major_grid.ExpertSymbol(ExpertSymbol());
    minor_grid.ExpertSymbol(ExpertSymbol());
   }
void CGridDouble::Init(int major_trend,int major_add,int minor_trend,int minor_add)
   {
       trend_points_major=major_trend;
    trend_points_minor=minor_trend;
    add_points_major=major_add;
    add_points_minor=minor_add;
    tp_major=CalTP(trend_points_major,add_points_major,0);
    tp_minor=CalTP(trend_points_minor,add_points_minor,15-int(trend_points_minor/add_points_minor));
    major_grid.Init(0.01,ENUM_GRID_LOTS_EXP_NUM,int(trend_points_major/add_points_major));
    minor_grid.Init(0.01,ENUM_GRID_LOTS_EXP_NUM,int(trend_points_minor/add_points_minor));
    major_grid.ExpertMagic(ExpertMagic()+0);
    minor_grid.ExpertMagic(ExpertMagic()+1);
    major_grid.ExpertSymbol(ExpertSymbol());
    minor_grid.ExpertSymbol(ExpertSymbol());
   }
   
int CGridDouble::CalTP(int trend_p,int add_p, int pos_add=0)
   {
//   根据趋势长度和网格大小确定仓位数，以及计算手数的指数函数对应的系数
   int pos_num=int(trend_p/add_p);
   double alpha,beta;
   beta=MathLog(100)/(pos_num-1);
   alpha=1/MathExp(beta);
//   计算止盈出场点，满足在给定的趋势范围内，一定止盈出场；
   double sum_product=0;
   double sum_lots=0;
   for(int i=1;i<pos_num+1+pos_add;i++)
     {
      sum_lots+=NormalizeDouble(0.01*alpha*exp(beta*i),2);
      sum_product+=NormalizeDouble(0.01*alpha*exp(beta*i),2)*i;
     }
   int points_win=int(add_p*(pos_num-sum_product/sum_lots));
   return points_win;
   } 
void CGridDouble::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      major_grid.RefreshTickPrice();
      minor_grid.RefreshTickPrice();
      major_grid.RefreshPositionState();
      minor_grid.RefreshPositionState();
      
      TimeToStruct(TimeCurrent(),dt);
      if(dt.hour*60+dt.min>23*60+50 || dt.hour*0+dt.min<10) return; // 前后日切换时候的20分钟不进行开仓交易
      
      MajorGridOperate();
      major_grid.RefreshPositionState();
      MinorGridOperate();
     
     }
  }
void CGridDouble::MajorGridOperate(void)
   {
    if(major_grid.pos_state.num_buy==0) // 主网格多头空仓进行开仓
        {
         major_grid.BuildLongPositionWithTP(tp_major);
        }
      else if(major_grid.DistanceAtLastBuyPrice()>add_points_major) // 主网格多头持仓，且达到加仓条件进行加仓
        {
         major_grid.BuildLongPositionWithTP(tp_major);
        }
     if(major_grid.pos_state.num_sell==0) // 主网格多头空仓进行开仓
        {
         major_grid.BuildShortPositionWithTP(tp_major);
        }
      else if(major_grid.DistanceAtLastSellPrice()>add_points_major) // 主网格多头持仓，且达到加仓条件进行加仓
        {
          major_grid.BuildShortPositionWithTP(tp_major);
        }
   }
void CGridDouble::MinorGridOperate(void)
   {
    if(minor_grid.pos_state.num_buy==0) // 次网格多头空仓进行开仓
      {
        if(major_grid.pos_state.num_sell-major_grid.pos_state.num_buy>5)
         {
          minor_grid.BuildLongPositionWithTP(tp_minor);
         }
      }
    else if(minor_grid.DistanceAtLastBuyPrice()>add_points_minor) // 次网格多头持仓，且达到加仓条件进行加仓
        {
         minor_grid.BuildLongPositionWithTP(tp_minor);
        }
        
    if(minor_grid.pos_state.num_sell==0) // 次网格多头空仓进行开仓
      {
       if(major_grid.pos_state.num_buy-major_grid.pos_state.num_sell>5)
         {
          minor_grid.BuildShortPositionWithTP(tp_minor);
         }
      }
    else if(minor_grid.DistanceAtLastSellPrice()>add_points_minor) // 次网格多头持仓，且达到加仓条件进行加仓
        {
          minor_grid.BuildShortPositionWithTP(tp_minor);
        }     
   }
//void CGridDouble::MinorGridOperate(void)
//   {
//    if(minor_grid.pos_state.num_buy==0) // 次网格多头空仓进行开仓
//        {
//         minor_grid.BuildLongPositionWithTP(tp_minor);
//        }
//      else if(minor_grid.DistanceAtLastBuyPrice()>add_points_minor) // 次网格多头持仓，且达到加仓条件进行加仓
//        {
//         minor_grid.BuildLongPositionWithTP(tp_minor);
//        }
//     if(minor_grid.pos_state.num_sell==0) // 次网格多头空仓进行开仓
//        {
//         minor_grid.BuildShortPositionWithTP(tp_minor);
//        }
//      else if(minor_grid.DistanceAtLastSellPrice()>add_points_minor) // 次网格多头持仓，且达到加仓条件进行加仓
//        {
//          minor_grid.BuildShortPositionWithTP(tp_minor);
//        }
//   }