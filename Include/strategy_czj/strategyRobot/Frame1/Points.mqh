//+------------------------------------------------------------------+
//|                                                       Points.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPriceType:public CObject
  {
private:
   double            value;
   int               direction;
   datetime          time;
public:
                     CHPriceType(void){};
                     CHPriceType(double v,int d,datetime t);
                    ~CHPriceType(void){};
   double GetValue()  {return value;};
   int GetDirection() {return direction;};
   datetime GetTime() {return time;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPriceType::CHPriceType(double v,int d,datetime t)
  {
   value=v;
   direction=d;
   time=t;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPriceCharacter
  {
protected:
   int               adj_num;  // 判断极值点相邻bar数要求
   int               drop_points; // 判断极值点落差点数要求

   CArrayObj       hpt_arr;  // HPriceType数组
public:
                     CHPriceCharacter(void){};
                     CHPriceCharacter(int num_adj,int points_drop);
                    ~CHPriceCharacter(void){};
private:
   void              RatesToPoints(MqlRates &r[]);
   bool              IsMaxPoints(MqlRates &r[],int index);
   bool              IsMinPoints(MqlRates &r[],int index);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPriceCharacter::CHPriceCharacter(int num_adj,int points_drop)
  {
   adj_num=num_adj;
   drop_points=points_drop;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPriceCharacter::RatesToPoints(MqlRates &r[])
  {
   hpt_arr.Clear();
   for(int i=adj_num;i<ArraySize(r)-adj_num;i++)
     {
      if(IsMaxPoints(r,i))
        {
         CHPriceType *hpt=new CHPriceType(r[i].high,1,r[i].time);
         hpt_arr.Add(hpt);
        }
      if(IsMinPoints(r,i))
        {
         CHPriceType *hpt=new CHPriceType(r[i].low,-1,r[i].time);
         hpt_arr.Add(hpt);         
        }
     }
  }
bool CHPriceCharacter::IsMaxPoints(MqlRates &r[],int index)
   {
    
   }
bool CHPriceCharacter::IsMinPoints(MqlRates &r[],int index)
   {
    
   }     
//+------------------------------------------------------------------+
