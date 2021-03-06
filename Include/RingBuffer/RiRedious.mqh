//+------------------------------------------------------------------+
//|                                                    RiRedious.mqh |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
#include "RiBuffDBl.mqh"
//+------------------------------------------------------------------+
//|在环形缓存中计算序列的残差的标准差                      |
//+------------------------------------------------------------------+
class CRiRedious:public CRiBuffDbl
  {
private:
   double            redious[];
   double            m_sum;
   double            RediousMean(void);
protected:
   virtual void      OnAddValue(double value);
   virtual void      OnRemoveValue(double value);
   virtual void      OnChangeValue(int index,double del_value,double new_value);
public:
                     CRiRedious(void);
   double            PriceMean(void);
   double            RediousStd(void);
  };
//+------------------------------------------------------------------+
//| 初始化                                                                 |
//+------------------------------------------------------------------+
CRiRedious::CRiRedious(void)
  {
   m_sum=0.0;
  }
//+------------------------------------------------------------------+
//|     Increase the total sum                                                               |
//+------------------------------------------------------------------+
void CRiRedious::OnAddValue(double value)
  {
   m_sum+=value;
  }
//+------------------------------------------------------------------+
//| Decrease the total sum                                           |
//+------------------------------------------------------------------+
void CRiRedious::OnRemoveValue(double value)
  {
   m_sum-=value;
  }
//+------------------------------------------------------------------+
//| Change the total sum                                             |
//+------------------------------------------------------------------+
void CRiRedious::OnChangeValue(int index,double del_value,double new_value)
  {
   m_sum -= del_value;
   m_sum += new_value;
  }
//+------------------------------------------------------------------+
//|  序列的移动平均值                                                                |
//+------------------------------------------------------------------+
double CRiRedious::PriceMean(void)
  {
   return m_sum/GetTotal();
  }
//+------------------------------------------------------------------+
//| 残差的移动平均值                                                                 |
//+------------------------------------------------------------------+
double CRiRedious::RediousMean(void)
  {
   int num=GetTotal();
   double price[];
   double r_sum=0.0;
   double mean = PriceMean();
   ArrayResize(redious,num);
   ArrayResize(price,num);
//---复制价格序列
   ToArray(price);
//---计算残差序列
   for(int i=0;i<num;i++)
     {
      redious[i]=price[i]-mean;
      r_sum+=redious[i];
     }
   return r_sum/num;
  }
//+------------------------------------------------------------------+
//|残差的标准差                                                                  |
//+------------------------------------------------------------------+
double CRiRedious::RediousStd(void)
  {
   double sum_std=0.0;
   double r_mean=RediousMean();
   int num=GetTotal();
   for(int i=0;i<num;i++)
     {
         sum_std+=(redious[i]-r_mean)*(redious[i]-r_mean);
     }
    return MathSqrt(sum_std/(num-1));
  }
//+------------------------------------------------------------------+
