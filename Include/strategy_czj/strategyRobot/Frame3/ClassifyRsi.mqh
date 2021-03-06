//+------------------------------------------------------------------+
//|                                                 CClassifyRsi.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseClassify.mqh"
//+------------------------------------------------------------------+
//|            Rsi分类器                                             |
//+------------------------------------------------------------------+
class CClassifyRsi:public CBaseClassify
  {
protected:
   int               h_rsi;
   double            rsi_value[];
protected:
   void              SetComment();   
public:
                     CClassifyRsi(void){};
                    ~CClassifyRsi(void){};
   void              InitRsi(string sym,ENUM_TIMEFRAMES tf=PERIOD_H1,int tau=14);
   virtual void      CalClassifyResult();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassifyRsi::InitRsi(string sym,ENUM_TIMEFRAMES tf=16385,int tau=14)
  {
   symbol=sym;
   period=tf;
   cret=ENUM_CLASSIFY_REFRESH_BAR;
   h_rsi=iRSI(sym,tf,14,PRICE_CLOSE);
   SetTotal(6);
   SetComment();
   SetClassifyName("RSI分类器");
  }
void CClassifyRsi::SetComment()
   {
    class_comment[0]="RSI>75";
    class_comment[1]="70<RSI<75";
    class_comment[2]="50<RSI<70";
    class_comment[3]="30<RSI<50";
    class_comment[4]="25<RSI<30";
    class_comment[5]="RSI<25";
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassifyRsi::CalClassifyResult()
  {
   CopyBuffer(h_rsi,0,1,1,rsi_value);
   if(rsi_value[0]>75) class_result=0;
   else if(rsi_value[0]>70) class_result= 1;
   else if(rsi_value[0]>50) class_result= 2;
   else if(rsi_value[0]>30) class_result= 3;
   else if(rsi_value[0]>25) class_result= 4;
   else class_result=5;
  }
//+------------------------------------------------------------------+
