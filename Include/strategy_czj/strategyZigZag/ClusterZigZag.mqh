//+------------------------------------------------------------------+
//|                                                ClusterZigZag.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include <Math\Alglib\alglib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CClusterZigZag:public CStrategy
  {
private:
   int               handle_zigzag; // 句柄
   int               num_zigzag; // zigzag的数量
   CMatrixDouble     extreme_value;  // 非零的zigzag序列
   int               num_cluster;   // 聚类的数量
   int               num_extreme;   // 非0的极值数量
   CAlglib           alg;
   int               cluster_infor;
   CMatrixDouble     cluster_c;
   int               cluster_xyc[];
   MqlTick           latest_price;
   bool              cluster_success;
   double            order_lots;
   int infor;
   double c_sort[];
   
   bool is_in_region;
   bool has_buy;
   bool has_sell;
   
   double sl_buy;
   double sl_sell;
   
   double ratio_x;
   double ratio_y;
   double buy_up;
   double buy_down;
   double sell_up;
   double sell_down;
   
   double region_up_last;
   double region_down_last;
   double region_up;
   double region_down;
   
   double num_buy;
   double num_sell;
private:
   void RefreshStates();
   
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CalUpAndDownPrice();
public:
                     CClusterZigZag(void);
                    ~CClusterZigZag(void){};
   void              GetZigZagValues();  // 取zigzag的非0值
   void              Cluster(); // 对zigzag进行聚类
   void              GetClusterResult(int &info,double &c[],int &num_c[]);
   void              CreateHline();
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CClusterZigZag::CClusterZigZag(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   num_zigzag=1200;
   num_cluster=5;
   ratio_x=0.2;
   ratio_y=0.05;
   order_lots=0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClusterZigZag::GetZigZagValues(void)
  {
//复制zigzag指标数值--并取得极值点
   double zigzag_value[];
   CopyBuffer(handle_zigzag,0,0,num_zigzag,zigzag_value);
   //Print(ArraySize(zigzag_value));
   int counter=0;
   for(int i=0;i<num_zigzag;i++)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      counter++;
      extreme_value.Resize(counter,1);
      extreme_value[counter-1].Set(0,zigzag_value[i]);
     }
   num_extreme=counter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClusterZigZag::Cluster(void)
  {
   alg.KMeansGenerate(extreme_value,num_extreme,1,num_cluster,5,cluster_infor,cluster_c,cluster_xyc);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClusterZigZag::GetClusterResult(int &info,double &c[],int &num_c[])
  {
   info=cluster_infor;
   ArrayResize(c,num_cluster);
   ArrayResize(num_c,num_cluster);
   for(int i=0;i<num_cluster;i++)
     {
      //Print(cluster_c[0][i]);
      c[i]=cluster_c[0][i];
      int counter=0;
      for(int j=0;j<num_extreme;j++)
        {
         if(cluster_xyc[j]==i) counter++;
        }
      num_c[i]=counter;
     }
  }
CClusterZigZag::CreateHline(void)
   {
    for(int i=0;i<num_cluster;i++)
      {
       ObjectCreate(0,"hline"+string(i),OBJ_HLINE,0,0,cluster_c[0][i]);
      }
   }
void CClusterZigZag::CalUpAndDownPrice(void)
   {
    is_in_region=false;
    for(int i=0;i<num_cluster-1;i++)
      {
       if(c_sort[i]<latest_price.ask && c_sort[i+1]>latest_price.ask)
         {
          buy_down=c_sort[i]+(c_sort[i+1]-c_sort[i])*ratio_x;
          buy_up=c_sort[i]+(c_sort[i+1]-c_sort[i])*(ratio_x+ratio_y);
          sell_up=c_sort[i+1]-(c_sort[i+1]-c_sort[i])*ratio_x;
          sell_down=c_sort[i+1]-(c_sort[i+1]-c_sort[i])*(ratio_x+ratio_y);
          sl_buy = c_sort[i] - 0.5*(c_sort[i+1]-c_sort[i]);
          sl_sell = c_sort[i+1]+0.5*(c_sort[i+1]-c_sort[i]);
          region_down=c_sort[i];
          region_up=c_sort[i+1];
          if(buy_up<sell_down)
            {
               is_in_region=true;
            }
          break;
         }
      }
   }
void CClusterZigZag::RefreshStates(void)
   {
    num_buy = 0;
    num_sell =0;
    for(int i=0;i<PositionsTotal();i++)
      {
       ulong ticket = PositionGetTicket(i);
       PositionSelectByTicket(ticket);
       if(PositionGetInteger(POSITION_MAGIC)==ExpertMagic())
         {
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) num_buy++;
          else num_sell++;
         }
       
      }
   
   }
void CClusterZigZag::OnEvent(const MarketEvent &event)
   {
    // 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshStates();
      if(cluster_success)
        {
         CalUpAndDownPrice();
         if(is_in_region)
           {
            if(num_buy==0&&latest_price.ask>buy_down&&latest_price.ask<buy_up&&(region_down_last!=region_down &&region_up!=region_up_last))
              {
               Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,sl_buy,sell_down);
               region_down_last=region_down;
               region_up_last=region_up;
              }
            else if(num_sell==0&&latest_price.bid<sell_up&&latest_price.bid>sell_down&&(region_down_last!=region_down &&region_up!=region_up_last))
                   {
                    Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,sl_sell,buy_up);
                    region_down_last=region_down;
                    region_up_last=region_up;
                   }
           }
        }
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      GetZigZagValues();
      Cluster();
         int num_c[];
      GetClusterResult(infor,c_sort,num_c);
      ArraySort(c_sort);
      cluster_success=true;
     }
   
   }
//+------------------------------------------------------------------+
