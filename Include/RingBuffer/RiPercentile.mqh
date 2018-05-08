//+------------------------------------------------------------------+
//|                                                 RiPercentile.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, chizhijing."
#property link      "http://www.mql5.com"
#include "RiBuffDbl.mqh"
#include <Math\AlgLib\AlgLib.mqh>
//+------------------------------------------------------------------+
//| Calculate the main parameters of the Gaussian distribution       |
//+------------------------------------------------------------------+
class CRiPercentile : public CRiBuffDbl
{
private:
   double p;
   double value;
protected:
   virtual void  OnChangeArray(void);
public:
   void          SetP(double per){p=per;}
   double        PValue(void){ return value;}
};
//+------------------------------------------------------------------+
//| Calculation is performed in case of any array change             |
//+------------------------------------------------------------------+
void CRiPercentile::OnChangeArray(void)
{
   double array[];
   ToArray(array);
   CAlglib::SamplePercentile(array,p,value);
}
